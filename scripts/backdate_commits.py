import subprocess
import random
import os
from datetime import datetime, timedelta

def main():
    repo_dir = "/Users/aneeshkrishna/.gemini/antigravity/scratch/catenary"
    os.chdir(repo_dir)

    # 1. Get list of commits in forward chronological order (root to HEAD)
    res = subprocess.run(["git", "rev-list", "--reverse", "HEAD"], capture_output=True, text=True, check=True)
    commits = res.stdout.strip().split("\n")
    n_commits = len(commits)
    print(f"Found {n_commits} commits to rewrite.")

    # 2. Generate timestamps across ~7.8 months: 2019-10-24 to 2020-06-16
    random.seed(1337)
    start_dt = datetime(2019, 10, 24, 14, 23, 15)
    end_dt = datetime(2020, 6, 16, 21, 45, 30)
    total_seconds = (end_dt - start_dt).total_seconds()

    intervals = [random.uniform(0.6, 1.4) for _ in range(n_commits - 1)]
    sum_intervals = sum(intervals)

    current_time = start_dt
    timestamps = [current_time]

    for inv in intervals:
        step_seconds = (inv / sum_intervals) * total_seconds
        current_time = current_time + timedelta(seconds=step_seconds)
        hr = random.randint(9, 23)
        minute = random.randint(0, 59)
        second = random.randint(0, 59)
        ts = datetime(current_time.year, current_time.month, current_time.day, hr, minute, second)
        if ts <= timestamps[-1]:
            ts = timestamps[-1] + timedelta(hours=random.randint(4, 12), minutes=random.randint(1, 59))
        timestamps.append(ts)

    # 3. Rewrite commit tree
    new_parent = None
    author_name = "Aneesh"
    author_email = "aneeshkrishnaparthasarathy@gmail.com"

    for idx, (old_commit, ts) in enumerate(zip(commits, timestamps)):
        ts_str = ts.strftime("%Y-%m-%d %H:%M:%S") + " -0500"

        # Get tree hash
        tree_res = subprocess.run(["git", "rev-parse", f"{old_commit}^{{tree}}"], capture_output=True, text=True, check=True)
        tree = tree_res.stdout.strip()

        # Get commit message
        msg_res = subprocess.run(["git", "log", "-1", "--format=%B", old_commit], capture_output=True, text=True, check=True)
        msg = msg_res.stdout

        # Prepare env
        env = os.environ.copy()
        env["GIT_AUTHOR_NAME"] = author_name
        env["GIT_AUTHOR_EMAIL"] = author_email
        env["GIT_AUTHOR_DATE"] = ts_str
        env["GIT_COMMITTER_NAME"] = author_name
        env["GIT_COMMITTER_EMAIL"] = author_email
        env["GIT_COMMITTER_DATE"] = ts_str

        cmd = ["git", "commit-tree", tree]
        if new_parent:
            cmd.extend(["-p", new_parent])
        cmd.extend(["-m", msg])

        commit_res = subprocess.run(cmd, env=env, capture_output=True, text=True, check=True)
        new_commit = commit_res.stdout.strip()
        new_parent = new_commit
        print(f"[{idx+1}/{n_commits}] {old_commit[:8]} -> {new_commit[:8]} @ {ts_str}")

    # 4. Update main ref
    subprocess.run(["git", "update-ref", "refs/heads/main", new_parent], check=True)
    print(f"\nBranch main updated to {new_parent}")

if __name__ == "__main__":
    main()
