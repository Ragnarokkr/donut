# Encrypts data and prints the result to the standard output.
export def "age-encrypt data" [
    data # data to encrypt
] {
    age -r (open $env.AGE_PRV_KEY | parse -r 'public key: (?P<pubkey>age1[[:alnum:]/=\-]{58})' | get pubkey.0) $data
}

# Encrypts an input file and save it into the output path
export def "age-encrypt file" [
    input: path  # input file name
    output: path # output file name
] {
    age -r (open $env.AGE_PRV_KEY | parse -r 'public key: (?P<pubkey>age1[[:alnum:]/=\-]{58})' | get pubkey.0) -o $output $input
}

# Decrypts data and prints out the result to the standard output.
export def "age-decrypt data" [
    data # data to decrypt
] {
    age --decrypt -i $env.AGE_PRV_KEY $data
}

# Decrypts an input file and save it into the output path
export def "age-decrypt file" [
    input: path  # input file name
    output: path # output file name
] {
    age --decrypt -i $env.AGE_PRV_KEY -o $output $input
}
