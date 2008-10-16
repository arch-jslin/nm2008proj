<?php

function verify_format($rank_str) {
    $check_array = split('[|]', $rank_str, 10); //we only allow 10 entries.
    if ( count( $check_array ) != 10 ) return FALSE;
    foreach( $check_array as $iter )
        //try to check if the string can be seen as int
        if( !is_int( 0 + $iter ) )
            return FALSE;
    return TRUE;
}

function write_score_to_ranks($rank_str) {
    if ( verify_format($rank_str) && ($fp = fopen('ranks','w')) ) {
        fwrite($fp, $rank_str);
        fclose($fp);
    }
}

write_score_to_ranks($_POST['obfuscated_name']);
//write_score_to_ranks($_GET['obfuscated_name']);  //use this when manual testing with broswer
//write_score_to_ranks('1|2|3|4|5|6|7|8|9|10');  //use this when manual testing locally

?>