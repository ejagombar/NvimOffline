FROM alpine:3.21

ENV TERM=xterm-256color \
    EDITOR=nvim

RUN apk add musl-dev bash clang-dev g++ man-pages cmake tmux neovim neovim-doc fzf ripgrep 

COPY . /root/.config/nvim

RUN ln -sf /root/.config/nvim/pack/offline/start/tmux.nvim/tmux.nvim.tmux /root/.tmux.conf

CMD ["bash"]
