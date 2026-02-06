# Lists all files.
def --wrapped l [...rest] {
    if ($rest | is-empty) {
        ls -a .
    } else {
        ls -a ...($rest | each {|p| if ($p | str contains '~') { $p | path expand } else { $p } } )
    }
}

# Lists directory items in long format.
def --wrapped ll [...rest] {
    if ($rest | is-empty) {
        ls -al .
    } else {
        ls -al ...($rest | each {|p| if ($p | str contains '~') { $p | path expand } else { $p } } )
    } | reject num_links inode created accessed
}

# Prints out cheatsheets
def cheat [search_query?: string] {
  http get --headers { User-Agent: "curl" } cheat.sh/($search_query)
}

# Generate a comment into the style of a specified programming language.
@example 'Generate a header comment for C, 80 chars width, centered' { comment generate "THIS IS A HEADER" }
@example 'Generate a sub-header comment Python, 75 chars width, centered' { comment generate "THIS IS A SUB-HEADER" -l py -w 75 -s sub-header }
def "comment generate" [
    text: string = ''               # text of the comment; it can be multilines
    --language (-l): string = 'c'   # language
    --width (-w): int = 80
    --align (-a): string = 'center'
    --style (-s): string = 'header' # header, sub-header, divider
    --filled (-f)                   # fill the spaces
    --single-line (-S)              # single line comment
    --list
] {
    const C_STYLE_LANGUAGES = [c cpp c3 d js ts jsonc]
    const BASH_STYLE_LANGAUGES = [sh nu py]

    if $list {
        $C_STYLE_LANGUAGES | append $BASH_STYLE_LANGAUGES | sort
    } else {

        const SAFETY_MARGIN = 2

        let comment_symbol = match $language {
            $lang if $lang in $C_STYLE_LANGUAGES => { '//' }
            $lang if $lang in $BASH_STYLE_LANGAUGES => { '#' }
            _ => { '//' }
        }

        let real_width = $width - $SAFETY_MARGIN - ($comment_symbol | str length) - 1

        match $style {
            "header" => {
                const char = '='
                let filler = if $filled { $char } else { ' ' }
                if not $single_line {
                    ($comment_symbol + ' ' + ('' | fill -w $real_width -c $char) + (char newline) +
                        ($text | lines | each {$comment_symbol + ' ' + ($in | fill -w $real_width -a $align -c $filler) } | str join (char newline)) + (char newline) +
                        $comment_symbol + ' ' + ('' | fill -w $real_width -c $char) + (char newline)
                    )
                } else {
                    $comment_symbol + ' ' + ($text | fill -w $real_width -a $align -c $filler) + (char newline)
                }
            }
            "sub-header" => {
                const char = '-'
                let filler = if $filled { $char } else { ' ' }
                if not $single_line {
                    ($comment_symbol + ' ' + ('' | fill -w $real_width -c $char) + (char newline) +
                        ($text | lines | each {$comment_symbol + ' ' + ($in | fill -w $real_width -a $align -c $filler) } | str join (char newline)) + (char newline) +
                        $comment_symbol + ' ' + ('' | fill -w $real_width -c $char) + (char newline)
                    )
                } else {
                    $comment_symbol + ' ' + ($text | fill -w $real_width -a $align -c $filler) + (char newline)
                }
            }
            "divider" => {
                const char = '~'
                $comment_symbol + ' ' + ('' | fill -w $real_width -c $char) + (char newline)
            }
        }
    }
}

# Convert a Github Flavoured Markdown file into a HTML file.
def "preview gfm" [
    in_path: path                       # input md file
    out_path: path                      # output html file
    --force (-f)                        # force the remote GFM CSS
    --processor (-p): string = "cmark"  # 'cmark' or 'pandoc'
    --watch (-w)                        # watching for changes
] {
    const GFM_CSS_URL = 'https://cdn.jsdelivr.net/npm/github-markdown-css/github-markdown.min.css'
    const GFM_CSS_PATH: path = $nu.cache-dir | path join 'github-markdown.min.css'
    const GFM_TEMPLATE = '<!DOCTYPE html><html><head><meta charset="utf-8"><style>%css%</style></head><body class="markdown-body">%body%</body></html>'

    let cmark: closure = {|css, input|
        $GFM_TEMPLATE
        | str replace '%css%' (open $css)
        | str replace '%body%' (cmark-gfm --extension table --table-prefer-style-attributes --unsafe $input)
    }

    let pandoc: closure = {|css, input|
        $GFM_TEMPLATE
        | str replace '%css%' (open $css)
        | str replace '%body%' (pandoc -f gfm -t html --embed-resources --syntax-highlight="default" $input)
    }

    if not ($GFM_CSS_PATH | path exists) or ((date now) - (ls $GFM_CSS_PATH | get modified.0) > 4wk) or $force {
        http get $GFM_CSS_URL | save -f $GFM_CSS_PATH
    }

    let $available_processor: string = (
        match $processor {
            'cmark' => { if (which cmark-gfm | is-not-empty) { 'cmark' } }
            'pandoc' => { if (which pandoc  | is-not-empty) { 'pandoc' } }
            _ => { if (which cmark-gfm | is-not-empty) { 'cmark' } else if (which pandoc | is-not-empty) { 'pandoc' } }
        }
    )

    match $available_processor {
        'cmark' => {
            if $watch {
                watch $in_path {|_, path| do $cmark $GFM_CSS_PATH $path | save -f $out_path}
            } else {
                do $cmark $GFM_CSS_PATH $in_path | save -f $out_path
            }
        }
        'pandoc' => {
            if $watch {
                watch $in_path {|_, path| do $pandoc $GFM_CSS_PATH $path | save -f $out_path}
            } else {
                do $pandoc $GFM_CSS_PATH $in_path | save -f $out_path
            }
        }
        _ => {
            error make { msg: "none of supported processors is installed on your system." }
        }
    }
}
