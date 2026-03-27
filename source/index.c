/*
* File         : index.c
* classic ID   : UCC-0091-4426
* UUID         : 4383df26-c39a-4461-8be7-71a4bd51f10b
*
* Type         : Entry Point
* Description  : Main entry point for this program
*
* Author       : Uoc Tamika
* Author ID    : 1
*
* License      : GNU GPL V2
*
*/

#include <ucc/tools/pch.h>
#include <ucc/tools/color.h>

int main(int argc, char *argv[])
{

    if(argc < 2)
    {
       fprintf(stderr, ANSI_BOLD_RED "Error: " ANSI_RESET "Missing input file\n");
       printf("Use yuc <file_name>.u\n");
       exit(-1);
    }


    return 0;
}
