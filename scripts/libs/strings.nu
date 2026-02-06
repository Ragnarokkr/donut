# Provides minimum templating functionalities

# Replaces all references into a template string from provided data.
@example 'Replaces simple references' '"{what} is equal to {value}" | template { what: "PI" value: 3.14159 }'
@example 'Replaces nested references' '"{http.method} returned {response.status}" | template { http: { method: "GET" } response: { status: 404 } }'
@search-terms template
export def template [
    data: record # record where the data is retrieved from
]: string -> string {
    let input: string = $in

    if ($input | is-empty) { return '' }
    if ($data | is-empty) { return $input }

    mut $out = $input

    let segments = $out | parse -r "{(?<segments>.+?)}"
    for ref in $segments {
        $out = $out | str replace -a -n $"{($ref.segments)}" (try {
            let cell_path = $ref.segments | split row '.' | into cell-path
            let value = $data | get $cell_path
            match ($value | describe) {
                int => { $value | into string }
                bool => { $value | into string }
                string => { $value }
                $m if ($m | str contains 'record') => { $value | to nuon }
                $m if ($m | str contains 'list') => { $value | to nuon }
                $m if ($m | str contains 'table') => { $value | to nuon }
                _ => { '' }
            }
        } catch {
            ''
        })
    }

    $out
}
