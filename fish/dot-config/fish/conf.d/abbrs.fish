# ~/.config/fish/conf.d/abbrs.fish

if status is-interactive
    abbr -a vim "nvim"
    abbr -a oc "opencode"
    abbr -a vimcode "nvim -c NvimTreeToggle"
    abbr -a vimrc "nvim ~/.vimrc"

    abbr -a tree "tree -I node_modules -I .git"
    abbr -a grep "rg"

    abbr -a ll "eza -l -g --icons=auto"
    abbr -a ls "eza --icons=auto"

    abbr -a klogs "kubectl logs -f --tail 100"
    abbr -a k "kubectl"

    abbr -a sshpihole "ssh -L 8002:localhost:80 ubuntu@aws-tg4-small"
    abbr -a kpflonghorn "kubectl port-forward svc/longhorn-frontend -n longhorn-system 8003:80"
    abbr -a kpfargocd "kubectl port-forward -n argocd svc/argocd-server 8004:443"

    abbr -a python "python3"
end
