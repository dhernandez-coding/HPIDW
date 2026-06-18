import os
import sys
import subprocess
from datetime import datetime

# Path setups
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
ENV_PATH = os.path.join(BASE_DIR, ".env")

def load_env(path):
    """Fallback custom parser for .env files to avoid external dependencies."""
    config = {}
    if os.path.exists(path):
        with open(path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                if "=" in line:
                    key, val = line.split("=", 1)
                    config[key.strip()] = val.strip()
    return config

def get_git_executable():
    """Locate the git executable in standard Windows paths if not on environment PATH."""
    try:
        subprocess.run(["git", "--version"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
        return "git"
    except (FileNotFoundError, subprocess.CalledProcessError):
        pass

    # Standard Windows install locations
    common_paths = [
        r"C:\Program Files\Git\bin\git.exe",
        r"C:\Program Files\Git\cmd\git.exe",
        r"C:\Program Files (x86)\Git\bin\git.exe",
        r"C:\Program Files (x86)\Git\cmd\git.exe",
        os.path.expandvars(r"%LocalAppData%\Programs\Git\cmd\git.exe"),
        os.path.expandvars(r"%LocalAppData%\Programs\Git\bin\git.exe"),
    ]
    for path in common_paths:
        if os.path.exists(path):
            return path
    return None

def run_git_cmd(git_bin, args, cwd=BASE_DIR, secure_input=None):
    """Run a git command, securely masking passwords in output."""
    cmd = [git_bin] + args
    
    # Format cmd string for print (masking token)
    cmd_str = " ".join(cmd)
    if secure_input:
        cmd_str = cmd_str.replace(secure_input, "****")
        
    print(f"Executing: {cmd_str}")
    
    result = subprocess.run(cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    
    # Mask output log
    stdout_masked = result.stdout
    stderr_masked = result.stderr
    if secure_input:
        stdout_masked = stdout_masked.replace(secure_input, "****")
        stderr_masked = stderr_masked.replace(secure_input, "****")
        
    if result.returncode != 0:
        print(f"Error executing command: {result.returncode}")
        if stdout_masked.strip():
            print(f"STDOUT: {stdout_masked}")
        if stderr_masked.strip():
            print(f"STDERR: {stderr_masked}")
        raise subprocess.CalledProcessError(result.returncode, cmd, output=stdout_masked, stderr=stderr_masked)
        
    return stdout_masked

def main():
    print("Loading Git Push Configuration...")
    config = load_env(ENV_PATH)
    
    pat = config.get("GITHUB_PAT", "")
    repo_url = config.get("GITHUB_REPO_URL", "")
    branch = config.get("GITHUB_BRANCH", "main")
    committer_name = config.get("GIT_COMMITTER_NAME", "David Hernandez")
    committer_email = config.get("GIT_COMMITTER_EMAIL", "dhernandez-coding@users.noreply.github.com")
    
    if not pat or "PLACEHOLDER" in pat:
        print("\n[WARNING] GITHUB_PAT is not configured in the .env file.")
        print("Please edit 'C:\\ModMed\\db_backup\\.env' and put your Personal Access Token first.")
        sys.exit(1)
        
    if not repo_url:
        print("\n[ERROR] GITHUB_REPO_URL is not defined in the .env file.")
        sys.exit(1)
        
    # Locate git
    git_bin = get_git_executable()
    if not git_bin:
        print("\n[ERROR] Git was not found on your system PATH or standard installation directories.")
        print("Please install Git for Windows (https://git-scm.com/) to continue.")
        sys.exit(1)
        
    # Check if .git exists, initialize it if not
    git_dir = os.path.join(BASE_DIR, ".git")
    if not os.path.exists(git_dir):
        print("Initializing new Git repository...")
        run_git_cmd(git_bin, ["init"])
        
    # Configure local git user to avoid commits failing due to lack of identity
    run_git_cmd(git_bin, ["config", "user.name", committer_name])
    run_git_cmd(git_bin, ["config", "user.email", committer_email])
    
    # Configure remote URL with token securely
    # https://<token>@github.com/owner/repo.git
    secure_url = repo_url
    if repo_url.startswith("https://"):
        secure_url = repo_url.replace("https://", f"https://{pat}@")
    elif repo_url.startswith("http://"):
        secure_url = repo_url.replace("http://", f"http://{pat}@")
        
    # Add or update remote origin
    try:
        run_git_cmd(git_bin, ["remote", "remove", "origin"])
    except subprocess.CalledProcessError:
        pass # Origin didn't exist, which is fine
        
    run_git_cmd(git_bin, ["remote", "add", "origin", secure_url], secure_input=pat)
    
    # Stage all files
    print("Staging backup SQL files...")
    run_git_cmd(git_bin, ["add", "."])
    
    # Check if there are any changes to commit
    status_output = run_git_cmd(git_bin, ["status", "--porcelain"])
    if not status_output.strip():
        print("No changes detected since the last backup. Nothing to push.")
        return
        
    # Commit changes
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    commit_msg = f"Nightly DB Schema Backup - {timestamp}"
    print(f"Committing changes: {commit_msg}")
    run_git_cmd(git_bin, ["commit", "-m", commit_msg])
    
    # Push to GitHub repository
    print(f"Pushing updates to GitHub branch '{branch}'...")
    try:
        run_git_cmd(git_bin, ["push", "-u", "origin", f"head:{branch}"], secure_input=pat)
        print("\nBackup successfully pushed to GitHub!")
    except subprocess.CalledProcessError as e:
        print("\n[ERROR] Failed to push to GitHub repository.")
        print("Please check if the GITHUB_PAT token in '.env' is correct and has 'repo' scopes enabled.")
        sys.exit(1)

if __name__ == "__main__":
    main()
