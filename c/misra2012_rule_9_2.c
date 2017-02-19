#include <stdio.h>

void print_array(int array[2][2])
{
    for(int i = 0; i < 2; i++) {
        for(int j = 0; j < 2; j++) {
            printf("%d ", array[i][j]);
        }
        printf("\n");
    }
}

int main()
{
    int z1[ 2 ][ 2 ] = { { 1 }, [ 1 ][ 1 ] = 2 };                 /* Compliant     */
    int z2[ 2 ][ 2 ] = { { 1 }, [ 1 ][ 1 ] = 2, [ 1 ][ 0 ] = 3 }; /* Compliant     */
    int z3[ 2 ][ 2 ] = { { 1 }, [ 1 ][ 0 ] = 2, 3 };              /* Non-compliant */
    int z4[ 2 ][ 2 ] = { [ 0 ][ 1 ] = 1, { 2, 3 } };              /* Compliant     */

    print_array(z1);
    /* 1 0
     * 0 2 */

    print_array(z2);
    /* 1 0
     * 3 2 */

    print_array(z3);
    /* 1 0
     * 2 3 */

    print_array(z4);
    /* 1 0
     * 2 3 */

    return 0;
}
