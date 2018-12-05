BEGIN{
    time1=0
    time2=0
    pack1=0
    pack2=0
    count1=0
    count2=0
}
{
    if( $1=="r" && $4=="AGT" && $3=="_1_") {
        count1++
        pack1 = pack1 + $8
        time1 = $2
    }
    if($1=="r"&&$4=="AGT"&&$3=="_2_") {
        count2++
        pack2 = pack2 + $8
        time2 = $2
    }
}
END{
    printf("1 : %f" , ((count1*pack1*8)/(10000000*time2)))
    printf("2 : %f" , ((count2*pack2*8)/(10000000*time1)))
}