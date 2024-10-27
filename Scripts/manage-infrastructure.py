import os
import sys
import subprocess
import argparse
import datetime

APPLICATION_NAME = "ccsa-ga-test-aws-infra"

def execute_command(command):
    """Executes a shell command and raises an error if it fails."""
    try:
        subprocess.run(command, check=True, shell=True)
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {e}")
        sys.exit(1)

def create_update_change_set(stack_name, stack_template, stack_parameters):
    print("==============================")
    print(f"Creating changeset for stack: {stack_name}")
    print("==============================")

    command = (
        f"aws cloudformation deploy "
        f"--no-execute-changeset "
        f"--no-fail-on-empty-changeset "
        f"--stack-name \"{stack_name}\" "
        f"--template-file \"{stack_template}\" "
        f"--parameter-overrides $(cat \"{stack_parameters}\")"
    )
    execute_command(command)

def deploy(stack_name, stack_template, stack_parameters):
    print("==============================")
    print(f"Deploying stack: {stack_name}")
    print("==============================")

    command = (
        f"aws cloudformation deploy "
        f"--no-fail-on-empty-changeset "
        f"--stack-name \"{stack_name}\" "
        f"--template-file \"{stack_template}\" "
        f"--parameter-overrides $(cat \"{stack_parameters}\")"
    )
    execute_command(command)

def handle_resources(environment_name, action):
    parameters_dir = f"Infrastructure/Parameters/{environment_name}"

    print(f"Checking parameters directory: {parameters_dir}")

    if not os.path.isdir(parameters_dir):
        print(f"Error: Parameters directory for environment {environment_name} does not exist.")
        sys.exit(1)

    print(f"Looking for .properties files in {parameters_dir}")

    param_files = [f for f in os.listdir(parameters_dir) if f.endswith('.properties')]
    if not param_files:
        print(f"No .properties files found in {parameters_dir}")
        return

    for param_file in param_files:
        param_file_path = os.path.join(parameters_dir, param_file)
        
        # Extract resource type and unique identifier from the parameter file name
        base_name = os.path.splitext(param_file)[0]
        resource_type = base_name.split('-')[0]
        unique_identifier = '-'.join(base_name.split('-')[1:])

        # Determine the corresponding template file
        template_file = f"Infrastructure/Templates/{resource_type}.yml"
        if not os.path.isfile(template_file):
            print(f"Error: Template file {template_file} does not exist.")
            continue

        # Create the stack name
        stack_name = f"{APPLICATION_NAME}-{environment_name}-{resource_type}"

        # Append unique_identifier if it's not empty and not the same as resource_type
        if unique_identifier and unique_identifier != resource_type:
            stack_name += f"-{unique_identifier}"

        if action == "create-changeset":
            print(f"Creating changeset for stack: {stack_name} using {param_file}")
            create_update_change_set(stack_name, template_file, param_file_path)
        elif action == "deploy":
            print(f"Deploying stack: {stack_name} using {param_file}")
            deploy(stack_name, template_file, param_file_path)
        else:
            print(f"Unsupported action: {action}")
            sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description="Manage AWS infrastructure.")
    parser.add_argument("--environment-name", required=True, help="Target environment where AWS resources will be managed.")
    parser.add_argument("--action", required=True, choices=["create-changeset", "deploy"], help="Action to perform.")
    parser.add_argument("--debug", type=bool, default=False, help="Enable debug logging.")

    args = parser.parse_args()

    print("==============================")
    print(f"[START] Infrastructure management started at {datetime.datetime.now().strftime('%d-%m-%Y %H:%M')}")
    print("==============================")

    handle_resources(args.environment_name, args.action)

    print(f"[END] {args.action.capitalize()} ran successfully.")

if __name__ == "__main__":
    main()
