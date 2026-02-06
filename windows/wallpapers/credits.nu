#!/usr/bin/env nu

const work_dir = path self | path dirname
let json = open ([$work_dir wallpapers.json] | path join)

print $"# Credits(char newline newline)"
$json | each {|| print $"- ![($in.image_file)]\(($in.image_file)\)(char newline)  [($in.image_file)]\(($in.url))(char newline)"} | ignore
