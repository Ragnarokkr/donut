#!/usr/bin/env nu

const TEMPLATE_PATH: path = path self 'README.tmpl.md'
const TARGET_README: path = path self '../README.md'

print $"Analyzing the template (ansi green)($TEMPLATE_PATH)(ansi reset)"
mut headings: list<string> = open $TEMPLATE_PATH
| lines -s
| parse -r '^(?<level>#{2,6}) (?<title>.+)$'
| collect
| drop nth 0
print $"Found (ansi attr_bold)($headings | length)(ansi reset) chapters."

print 'Building the TOC...'
$headings = $headings
| each {|i|
    let indent: string = '' | fill -w (4 * (($i.level | str length) - 2))
    let link: string = $i.title
    | str downcase
    | str replace -a ' ' '-'
    | str replace -ar '[^a-z0-9\-]' ''
    $"($indent)- [($i.title)]\(#($link))"
}

print $"Saving the generated TOC to (ansi yellow)($TARGET_README)(ansi reset)."
open $TEMPLATE_PATH
| str replace '{TOC}' ($headings | str join (char newline))
| save -f $TARGET_README
