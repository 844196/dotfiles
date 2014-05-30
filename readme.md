# dotfiles

## setup

```sh
$ git clone https://github.com/844196/dotfiles ~/dotfiles
$ sh ~/dotfiles/setup -i
```

## my script


### Vim

- `lightline-badwolf.vim`

    A [badwolf](https://github.com/sjl/badwolf/) like colorscheme for [lightline](https://github.com/itchyny/lightline.vim)  
    -> <https://github.com/844196/lightline-badwolf.vim>

    ![](https://farm6.staticflickr.com/5549/14256864394_57caec4640_c.jpg)

- `Log.vim`

    Converte Flickr share tag(HTML) to markdown language img tag. (benri)

    ![](http://img.f.hatena.ne.jp/images/fotolife/s/s083027/20140131/20140131032902.gif)
- `memo.vim`

    Browse memo in `g:logpath` and offer memo templete (requires [Unite](https://github.com/Shougo/unite.vim))

    ![](https://farm4.staticflickr.com/3770/14119306500_6d36417cf6_c.jpg)


### Shell

- `setup`

    Install dotfiles. (`.vimrc`, `.vimshrc`, `.zshrc`, `.tmux.conf`)
    ```sh
    $ sh setup
    usage: setup [-icr]
        -i install dotfiles
        -c copy dotfiles (useful dotfiles test)
        -r remove dotfiles
    ```
- `ricty.sh`

    Generate Ricty and Ricty for Powerline.
- `sachikosay`

    Kawaii.
    ```sh
    $ sachikosay

    ボクのカワイさにやられましたね。そのままボクに見とれてて下さい

    ￣￣￣￣￣￣￣￣￣￣￣＼／￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣
                         , -――- 、
                      ／          ヽ、
                    /爻ﾉﾘﾉﾊﾉﾘlﾉ ゝ  l
                 ＜ﾉﾘﾉ‐'    ｰ  ﾘ ＞ }
                    l ﾉ ┃    ┃ l ﾉ  ﾉ
                    l人   r‐┐   !ﾉ＾)
                       ゝ ` ´ ‐＜´
    ```

### other

- `weather.sh`
- `localip`

    amari tsukatte nai...  
    sonouchi kaku.
