/* C言語において、VBでのWith文のようなものはありますか？ */
/* https://teratail.com/questions/22675 */

#include <stdio.h>

struct customer {
    char *name;
    char *url;
    char *city;
};

int main()
{
    struct customer the_customer = {
        "Coho Vineyard",
        "http://www.cohovineyard.com/",
        "Redmond"
    };

    printf("%s\n", the_customer.name);
    printf("%s\n", the_customer.url);
    printf("%s\n", the_customer.city);

    return 0;
}
