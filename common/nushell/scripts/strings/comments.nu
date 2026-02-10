# Generate a comment from a text or list, into the style of a specified programming language.
export def "comment generate" [
    --align (-a): string = 'center'     # comment alignment (`left`, `center`, `right`)
    --block (-b): string = 'single'     # block format (`single`, `multi-single`, `multi`)
    --filled (-f)                       # fill the spaces with a filler character
    --filler-divider: string = '~'      # filler character for divider comment
    --filler-header: string = '='       # filler character for header comment
    --filler-subheader: string = '-'    # filler character for sub-header comment
    --language (-l): string = 'c'       # language style
    --list                              # prints out all supported language styles
    --margin-left: int = 1              # left margin
    --margin-right: int = 1             # right margin
    --padding-left: int = 0             # left padding
    --padding-right: int = 0            # right padding
    --style (-s): string = 'header'     # comment style (`header`, `sub-header`, `divider`)
    --width (-w): int = 80              # max line width
]: [nothing -> string string -> string list<string> -> string] {
    const LANGUAGES = [
        {
            ext_filter: '^(c|cpp|c3|d|jsx?|tsx?|jsonc|rs)$'
            support: { single: single multi-single: multi-single multi: multi }
            symbol: { single_open: '//' single_close: '' multi_open: '/*' multi_close: '*/' }
        }
        {
            ext_filter: '^(zig)$'
            support: { single: single multi-single: single multi: single }
            symbol: { single_open: '//' single_close: '' multi_open: '' multi_close: '' }
        }
        {
            ext_filter: '^(sh|zsh|bash|nu|py)$'
            support: { single: single multi-single: multi-single multi: multi-single }
            symbol: { single_open: '#' single_close: '' multi_open: '#' multi_close: '' }
        }
        {
            ext_filter: '^(sql)$'
            support: { single: single multi-single: multi-single multi: multi }
            symbol: { single_open: '--' single_close: '' multi_open: '/*' multi_close: '*/' }
        }
        {
            ext_filter: '^(html|xhtml|xml)$'
            support: { single: single multi-single: multi-single multi: multi }
            symbol: { single_open: '<!--' single_close: '-->' multi_open: '<!--' multi_close: '-->' }
        }
        {
            ext_filter: '^(css)$'
            support: { single: single multi-single: multi-single multi: multi }
            symbol: { single_open: '/*' single_close: '*/' multi_open: '/*' multi_close: '*/' }
        }
    ]

    let get_net_width: closure = {|open: string, close: string|
        $width - ($open | str length) - $margin_left - $margin_right - ($close | str length)
    }

    let fill_line: closure = {|w: int, text: oneof<string, nothing>, solid: bool = false|
        let data: string = if not $solid {
            ('' | fill -w $padding_left) + $text + ('' | fill -w $padding_right)
        } else {
            ''
        }
        match $style {
            header => { $data | fill -w $w -a $align -c (if $filled or $solid { $filler_header } else { ' ' }) }
            sub-header => { $data | fill -w $w -a $align -c (if $filled or $solid { $filler_subheader } else { ' ' }) }
            divider => { '' | fill -w $w -a $align -c $filler_divider }
        }
    }

    let input = $in

    mut data: list<string> = if ($input | describe) == string { $input | split row (char newline) } else { $input }

    if $list {
        return ($LANGUAGES | each {|l|
            $l.ext_filter | str trim -c '(' | str trim -c ')' | split row '|'
        } | flatten | sort -i)
    }

    for lang in $LANGUAGES {
        if ($language | find -ir $lang.ext_filter | is-empty) { continue }

        if $style == divider {
            let net_width: int = do $get_net_width $lang.symbol.single_open $lang.symbol.single_close
            $data = [($lang.symbol.single_open
                + ('' | fill -w $margin_left) + (do $fill_line $net_width null true) + ('' | fill -w $margin_right)
                + $lang.symbol.single_close)]
            break
        }

        match ($lang.support | get $block) {
            single => {
                let net_width: int = do $get_net_width $lang.symbol.single_open $lang.symbol.single_close
                let delimiter: list<string> = [($lang.symbol.single_open + ('' | fill -w $margin_left) + (do $fill_line $net_width null true))]
                $data = $data | each {|l|
                    ($lang.symbol.single_open
                        + ('' | fill -w $margin_left) + (do $fill_line $net_width $l) + ('' | fill -w $margin_right)
                        + $lang.symbol.single_close)
                }
                $data = $delimiter ++ $data ++ $delimiter
            }
            multi-single => {
                let net_width: int = do $get_net_width $lang.symbol.multi_open $lang.symbol.multi_close
                let delimiter: list<string> = [($lang.symbol.multi_open + ('' | fill -w $margin_left) + (do $fill_line $net_width null true) + ('' | fill -w $margin_right) + $lang.symbol.multi_close)]
                $data = $data | each {|l|
                    ($lang.symbol.multi_open
                        + ('' | fill -w $margin_left) + (do $fill_line $net_width $l) + ('' | fill -w $margin_right)
                        + $lang.symbol.multi_close)
                }
                $data = $delimiter ++ $data ++ $delimiter
            }
            multi => {
                let net_width: int = do $get_net_width $lang.symbol.multi_open $lang.symbol.multi_close
                let margin: int = ($lang.symbol.multi_open | str length) + $margin_left
                let header: list<string> = [($lang.symbol.multi_open + ('' | fill -w $margin_left) + (do $fill_line $net_width null true))]
                let footer: list<string> = [(('' | fill -w $margin) + (do $fill_line $net_width null true) + ('' | fill -w $margin_right) + $lang.symbol.multi_close)]
                $data = $data | each {|l|
                    (('' | fill -w $margin) + (do $fill_line $net_width $l) + ('' | fill -w $margin_right))
                }
                $data = $header ++ $data ++ $footer
            }
        }
    }

    $data | str join (char newline)
}
