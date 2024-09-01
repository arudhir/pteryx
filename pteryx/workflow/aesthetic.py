from log import (
    log, 
    bold_yellow, 
    explanation, 
    bold_green, 
    black_yellow, 
    bold_white_purple, 
    bold_yellow_white, 
    bold_green_black, 
    bold_blue
)


def intro():
    log(get_ascii_art1())
    log(get_archaeopteryx_ascii2())
    explanation('a Panoply of Techniques for Elucidating Reconstructions by Yeeting eXhaustively')
    explanation('https://git.ginkgobioworks.com/aru/pteryx')
    explanation('maintainer: @aru')

def get_ascii_art1():
    ascii_art = (
            bold_blue(r".______   .___________. _______ .______     ____    ____ ___   ___ ") + "\n" +
            bold_blue(r"|   _  \  |           ||   ____||   _  \    \   \  /   / \  \ /  / ") + "\n" +
            bold_blue(r"|  |_)  | `---|  |----`|  |__   |  |_)  |    \   \/   /   \  V  /  ") + "\n" +
            bold_blue(r"|   ___/      |  |     |   __|  |      /      \_    _/     >   <   ") + "\n" +
            bold_blue(r"|  |          |  |     |  |____ |  |\  \----.   |  |      /  .  \  ") + "\n" +
            bold_blue(r"| _|          |__|     |_______|| _| `._____|   |__|     /__/ \__\ ") + "\n"
        )
    return ascii_art

def get_ascii_art2():
    ascii_art = (
        bold_yellow(r"______   ______   ______     ______     __  __     __  __    ") + "\n" +
        bold_yellow(r"/\  == \ /\__  _\ /\  ___\   /\  == \   /\ \_\ \   /\_\_\_\  ") + "\n" +
        bold_yellow(r"\ \  _-/ \/_/\ \/ \ \  __\   \ \  __<   \ \____ \  \/_/\_\/_ ") + "\n" +
        bold_yellow(r"\ \_\      \ \_\  \ \_____\  \ \_\ \_\  \/\_____\   /\_\/\_\ ") + "\n" +
        bold_yellow(r" \/_/       \/_/   \/_____/   \/_/ /_/   \/_____/   \/_/\/_/ ") + "\n"
    )
    return ascii_art

def get_ascii_art3():
    ascii_art = (
        bold_yellow(r"     .                   ") + "\n" +
        bold_yellow(r"    _|_                  ") + "\n" +
        bold_yellow(r".,-. |  .-. .--..  .-. ,-") + "\n" +
        bold_yellow(r"|   )| (.-' |   |  |  :  ") + "\n" +
        bold_yellow(r"|`-' `-'`--''   `--|-' `-") + "\n" +
        bold_yellow(r"|                  ;     ") + "\n" +
        bold_yellow(r"'               `-'      ")
    )
    return ascii_art

def get_archaeopteryx_ascii1():
    ascii_art = (
        bold_yellow(r"""                  .---.""") + "\n" +
        bold_yellow(r"""                 /     \\""") + "\n" +
        bold_yellow(r"""                 ) o    \\""") + "\n" +
        bold_yellow(r"""                /,-      \ \)_""") + "\n" +
        bold_yellow(r"""                V  )/)    \_) \\""") + "\n" +
        bold_yellow(r"""                    (    , \   \\""") + "\n" +
        bold_yellow(r"""              -_(-__ \  /   \   |""") + "\n" +
        bold_yellow(r"""              ,-/   `--'     \  |""") + "\n" +
        bold_yellow(r"""               /              \ |""") + "\n" +
        bold_yellow(r"""               |            )  \|""") + "\n" +
        bold_yellow(r"""               \       ,,,l`    `.""") + "\n" +
        bold_yellow(r"""                \     \ (        (""") + "\n" +
        bold_yellow(r"""                 \     ) \        \\""") + "\n" +
        bold_yellow(r"""                  \    l  `-\\_/    \\""") + "\n" +
        bold_yellow(r"""                   \  !     // `.   `-_""") + "\n" +
        bold_yellow(r"""                    \ )    //_-//\    (""") + "\n" +
        bold_yellow(r"""                     \ _-_// `-(  )    /""") + "\n" +
        bold_yellow(r"""                        `-(       `\   `,""") + "\n" +
        bold_yellow(r"""                                    \   /""") + "\n" +
        bold_yellow(r"""                                     (  ( BP""") + "\n" +
        bold_yellow(r"""                                      `-.;""") + "\n" +
        bold_yellow(r"""                                         `""") + "\n" 
    )
    return ascii_art

def get_archaeopteryx_ascii2():
    ascii_art = (
        bold_yellow(r"""                                                               ,,,,,,,,,,""") + "\n" +
        bold_yellow(r"""                                                             ,':.:.:.:../""") + "\n" +
        bold_yellow(r"""                                                           ,';,' ' ' ':./""") + "\n" +
        bold_yellow(r"""                                                         ,';,'' ' ' ' :./""") + "\n" +
        bold_yellow(r"""                                                       ,';.' ' ' ' ' ':./""") + "\n" +
        bold_yellow(r"""       ,                                             ,';.'' ' ' ' ' :';/ """) + "\n" +
        bold_yellow(r"""     ;: ;`;,,                                      ,';,' ' ' ' ' :': :`  """) + "\n" +
        bold_yellow(r"""     | ; ; ; ;`;'...                             ,';,'' ' ' ' :': :-`    """) + "\n" +
        bold_yellow(r"""     |;.;.;.; ; ; ; ;`;'...                    ,';,' ' ' ' :': :-`       """) + "\n" +
        bold_yellow(r"""     | : : : :':';.;.; ; ; ;`..              ,';,'' ' ' :': :-`          """) + "\n" +
        bold_yellow(r"""     |'.'.'.':.'.: : :':;.;,',';.         ,-';,' ' ' :': :-`             """) + "\n" +
        bold_yellow(r"""   `:|'.'.'.'.'.'.'.'.': : :':;,';.    ,-';,''' ' :': :-`                """) + "\n" +
        bold_yellow(r"""   __|.'.'.'.'.'.'.'.'.''.''.: :; ';.-';,''' ' :': :-`                   """) + "\n" +
        bold_yellow(r"""  '-==: ' ' ' ' ' ' '.'.'.'.'.': :;.;,''' ' '.:`:-`                      """) + "\n" +
        bold_yellow(r"""     __; ' ' ' ' ' ' ' ' ' '.''.':.' ' ' ' ::`.`     ,                   """) + "\n" +
        bold_yellow(r"""    /===`-'-:_:_' ' ' ' ' ' ' '.'.' ' ' '.:`.`      /|                   """) + "\n" +
        bold_yellow(r"""           ,    `: ' ' ' ' ' ' ' ' ' ' ::`.`.''''-..\\                   """) + "\n" +
        bold_yellow(r"""  l42    ////,    ) ' ' ' ' ' ' ' ' '.:`.`:' '.""...,\\                  """) + "\n" +
        bold_yellow(r"""        /'':':'.-: ' ' ' ' ' ' ' '.::`./.'.'.:      \\\\                 """) + "\n" +
        bold_yellow(r"""       //)'.'.'.'.' ' ' ' ' ' ' :'..:`./.'.'.'       \\\:'.              """) + "\n" +
        bold_yellow(r"""      | `/::-'.:.:_:_' ' ' ' '.'.:.:.`./-'-'           ``'               """) + "\n" +
        bold_yellow(r'''      | /:/          \' ' ' ''.'...:.`./                                 ''') + "\n" +
        bold_yellow(r'''      \\/:'            |' ' ' '.'..:`.`./                                ''') + "\n" +
        bold_yellow(r"""                      | ' ' ''.'..:`.`./                                 """) + "\n" +
        bold_yellow(r"""                      |' ' ' '.'..:`.`./                                 """) + "\n" +
        bold_yellow(r"""                     /' ' ' :'.'..:`.`./                                 """) + "\n" +
        bold_yellow(r"""                    /' ' '.'.'.'..:`.`./                                 """) + "\n" +
        bold_yellow(r"""                   /.'.'.'.'.'.'..:`.`./                                 """) + "\n" +
        bold_yellow(r"""                __| :''.'.'.'.'.::`. `./                                 """) + "\n" +
        bold_yellow(r"""               /==`.: :':':':':': : :`:.                                 """) + "\n" +
        bold_yellow(r"""                   //; : : : : : : : :.                                  """) + "\n" +
        bold_yellow(r"""                  |/  |.: : : : : `...`                                  """) + "\n" +
        bold_yellow(r"""                      ||`;,`,`,`,`..`                                    """) + "\n" +
        bold_yellow(r"""                      `'                                                 """) + "\n"
    )
    return ascii_art 
