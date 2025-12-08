{ name, email }: {
  enable = true;

  ignores = [
    ".DS_Store"
    "*.log"
    ".claude"
    "CLAUDE.md"
    "AGENTS.md"
    "lib.md"
  ];

  settings = {
    user = {
      inherit name email;
    };

    alias = {
      pf = "push --force-with-lease";
      pa = "!git add . && git commit --amend --no-edit && git push --force-with-lease";
      get = "!git stash push --include-untracked && git pull --rebase && git stash pop";
    };

    core = {
      editor = "nvim";
      fileMode = false;
      pager = "delta";
    };

    init.defaultBranch = "main";

    push = {
      autoSetupRemote = true;
      default = "current";
      forceWithLease = true;
    };

    credential.helper = "osxkeychain";

    pull.rebase = true;

    merge.conflictStyle = "zdiff3";

    net."git-fetch-with-cli" = true;

    interactive.diffFilter = "delta --color-only";
    delta.navigate = true;
  };
}

