! Copyright (c) 2024 Joseph Oziel
USING: accessors assocs command-line combinators.random io io.encodings.binary
io.files io.streams.string kernel math multiline namespaces
peg.ebnf prettyprint sequences ;

IN: 5050brainf

<PRIVATE

: 50-50 ( quot -- ) 
    0.5 swap [ ] ifp ; inline

TUPLE: 5050brainf pointer memory ;

: <5050brainf> ( -- 5050brainf )
    0 H{ } clone 5050brainf boa ;

: get-memory ( 5050brainf -- 5050brainf value )
    dup [ pointer>> ] [ memory>> ] bi at 0 or ;

: set-memory ( 5050brainf value -- 5050brainf )
    over [ pointer>> ] [ memory>> ] bi set-at ;

: (+) ( 5050brainf -- 5050brainf )                           
    [ get-memory 1 + 255 bitand set-memory ] 50-50 ;

: (-) ( 5050brainf -- 5050brainf )
    [ get-memory 1 - 255 bitand set-memory ] 50-50 ;
         
: (.) ( 5050brainf -- 5050brainf )
    get-memory write1 ;

: (,) ( 5050brainf -- 5050brainf )                
    read1 set-memory ;         
             
: (>) ( 5050brainf -- 5050brainf )
    [ [ 1 + ] change-pointer ] 50-50 ;

: (<) ( 5050brainf -- 5050brainf )
    [ [ 1 - ] change-pointer ] 50-50 ;

: compose-all ( seq -- quot )
    [ ] [ compose ] reduce ;

EBNF: parse-5050brainf [=[

inc-ptr  = ">"  => [[ [ (>) ] ]]
dec-ptr  = "<" => [[ [ (<) ] ]]
inc-mem  = "+"  => [[ [ (+) ] ]]
dec-mem  = "-"  => [[ [ (-) ] ]]
output   = "."  => [[ [ (.) ] ]]
input    = ","  => [[ [ (,) ] ]]
space    = [ \t\n\r]+ => [[ [ ] ]]
unknown  = (.)  => [[ [ ]  ]]

ops   = inc-ptr|dec-ptr|inc-mem|dec-mem|output|input|space
loop  = "[" {loop|ops}+ "]" => [[ second compose-all '[ [ get-memory zero? ] _ until ] ]]

code  = (loop|ops|unknown)*  => [[ compose-all ]]

]=]

PRIVATE>

MACRO: run-5050brainf ( code -- quot )
    parse-5050brainf '[ <5050brainf> @ drop flush ] ;

: get-5050brainf ( code -- result )
    [ run-5050brainf ] with-string-writer ; inline

<PRIVATE

: (run-5050brainf) ( code -- )
    [ <5050brainf> ] dip parse-5050brainf call( x -- x ) drop flush ;

PRIVATE>

: 5050brainf-main ( -- )
    command-line get [
        read-contents (run-5050brainf)
    ] [
        [ binary file-contents (run-5050brainf) ] each
    ] if-empty ;

MAIN: 5050brainf-main