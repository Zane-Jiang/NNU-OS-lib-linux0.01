int current = 0;
int key = 0 ;

int timer_interrupt(){
    if(key == 0){
        if(current == 0){
            current = 1;
        }else{
            if (current == 1)
            {
                current = 2;
            }else{
                if (current == 2)
                {
                    current = 3;
                }else{
                    // deflut current = 3
                    current =0;
                }
            }
        }
    }else{
        if(key = 'a'){
            // "a" --> press a & up a
            current = 0; 
        }else if(key = 'b'){
            current = 1;
        }else if(key = 'c'){
            current = 2;
        }else if(key = 'd'){
            current = 3;
        }
    }
}