FROM ubuntu:latest

ENV TERM=xterm-256color \
    EDITOR=nvim \
    NEOVIM_URL="https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz" \
    PATH="/opt/nvim/bin:$PATH"\
    LANG="en_US.UTF-8"

RUN apt-get update && apt-get install -y curl

# Download and extract Neovim
RUN mkdir -p /opt/nvim && \
    curl -L "$NEOVIM_URL" -o "/opt/nvim/nvim.tar.gz" && \
    tar -xzf "/opt/nvim/nvim.tar.gz" -C "/opt/nvim" --strip-components=1 && \
    ln -s /opt/nvim/bin/nvim "/usr/local/bin/nvim" && \
    rm -f "/opt/nvim/nvim.tar.gz"

RUN apt-get update && apt-get install -y bash clang clangd g++ manpages cmake tmux neovim ripgrep fd-find \
    && rm -rf /var/lib/apt/lists/*

COPY . /root/.config/nvim

# Ensure tmux config file exists before linking
RUN ln -sf /root/.config/nvim/pack/offline/start/tmux.nvim/.tmux.conf /root/.tmux.conf

CMD ["bash"]
