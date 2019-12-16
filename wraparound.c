/***********************************************************************
* File       : <2dstrfind.c>
*
* Author     : <M.R. Siavash Katebzadeh>
*
* Description:
*
* Date       : 08/10/19
*
***********************************************************************/
// ==========================================================================
// 2D String Finder
// ==========================================================================
// Finds the matching words from dictionary in the 2D grid

// Inf2C-CS Coursework 1. Task 3-5
// PROVIDED file, to be used as a skeleton.

// Instructor: Boris Grot
// TA: Siavash Katebzadeh
// 08 Oct 2019

#include <stdio.h>

// maximum size of each dimension
#define MAX_DIM_SIZE 32
// maximum number of words in dictionary file
#define MAX_DICTIONARY_WORDS 1000
// maximum size of each word in the dictionary
#define MAX_WORD_SIZE 10

int read_char() { return getchar(); }

int read_int() {
    int i;
    scanf("%i", &i);
    return i;
}

void read_string(char *s, int size) { fgets(s, size, stdin); }

void print_char(int c) { putchar(c); }

void print_int(int i) { printf("%i", i); }

void print_string(char *s) { printf("%s", s); }

void output(char *string) { print_string(string); }

// dictionary file name
const char dictionary_file_name[] = "dictionary.txt";
// grid file name
const char grid_file_name[] = "2dgrid.txt";
// content of grid file
char grid[(MAX_DIM_SIZE + 1 /* for \n */ ) * MAX_DIM_SIZE + 1 /* for \0 */ ];
// content of dictionary file
char dictionary[MAX_DICTIONARY_WORDS * (MAX_WORD_SIZE + 1 /* for \n */ ) + 1 /* for \0 */ ];
///////////////////////////////////////////////////////////////////////////////
/////////////// Do not modify anything above
///////////////Put your global variables/functions here///////////////////////
// starting index of each word in the dictionary
int dictionary_idx[MAX_DICTIONARY_WORDS];
// number of words in the dictionary
int dict_num_words = 0;


// function to print found word
void print_word(char *word) {
    while (*word != '\n' && *word != '\0') {
        print_char(*word);
        word++;
    }
}

// function to see if the string contains the (\n terminated) word
int contain(char *string, char *word) {
    while (1) {
        if (*string != *word) {
            return (*word == '\n');
        }
        string++;
        word++;
    }
}

int flag = 0;
int size[2] = {};
int diagonal;

void strfind(char *String, int row, char direction) {
    int idx = 0;
    int string_idx = 0;
    char *word;
    while (String[string_idx] != '\0') {
        for (idx = 0; idx < dict_num_words; idx++) {
            word = dictionary + dictionary_idx[idx];
            if (contain(String + string_idx, word)) {
                if (direction == 'H') { //changed this dramatically for wraparounds
                    if ((row < size[0]) && (string_idx < size[1])) {
                        printf("%d,%d %c", row, string_idx, direction);
                        print_char(' ');
                        print_word(word);
                        print_char('\n');
                        flag = 1;
                    }
                } else if (direction == 'V') {
                    if ((string_idx < size[0]) && (row < size[1])) {
                        printf("%d,%d %c", string_idx, row, direction);
                        print_char(' ');
                        print_word(word);
                        print_char('\n');
                        flag = 1;
                    }
                } else {
                    if (((row + string_idx) < size[0]) && ((diagonal + string_idx) < size[1])) {
                        printf("%d,%d %c", row + string_idx, diagonal + string_idx, direction);
                        print_char(' ');
                        print_word(word);
                        print_char('\n');
                        flag = 1;
                    }
                }

            }
        }

        string_idx++;
    }
}

void array_init(int arr[]) {
    int grid_idx = 0;
    int rows = 0;
    int flag = 0;
    while (grid[grid_idx] != '\0') {
        if (grid[grid_idx] == '\n') {
            if (flag == 0) {
                flag = 1;
                arr[1] = grid_idx;
            }
            rows++;
        }
        grid_idx++;
    }
    arr[0] = rows;

}

void strReset(char *string, int len) {
    int i;
    for (i = 0; i < len; i++) {
        string[i] = '\0';
    }
}

void wraparound(char *String) { //wraparound
    int i;
    int len;
    for (len = 0; len < MAX_DIM_SIZE * 2; len++) {
        if (String[len] == '\0') {
            break;
        }
    }
    for (i = len; i < 2 * len; i++) {
        String[i] = String[i - len];
    }
}

void parseHorizontal() {
    char helperString[MAX_DIM_SIZE * 2 + 1];
    strReset(helperString, MAX_DIM_SIZE * 2 + 1);
    int grid_idx = 0;
    int helper_idx = 0;
    int row = 0;
    while (row < size[0]) {
        if (grid[grid_idx] == '\n' || grid[grid_idx] == '\0') {
            wraparound(helperString); //wraparound
            strfind(helperString, row, 'H');
            strReset(helperString, MAX_DIM_SIZE * 2 + 1); //added for wraparound
            row++;
            helper_idx = 0;
        } else {
            helperString[helper_idx] = grid[grid_idx];
            helper_idx++;
        }
        grid_idx++;
    }

}


void parseVertical(int size[]) {
    char vString[MAX_DIM_SIZE * 2 + 1];
    strReset(vString, MAX_DIM_SIZE * 2 + 1);
    int grid_idx = 0;
    int helper_idx = 0;
    int row = 0;
    int offsetmult;
    for (grid_idx = 0; grid_idx < size[1]; grid_idx++) {
        helper_idx = 0;
        vString[helper_idx] = grid[grid_idx];
        for (offsetmult = 1; offsetmult < size[0]; offsetmult++) {
            helper_idx++;
            vString[helper_idx] = grid[grid_idx + offsetmult * size[1] + 1 * offsetmult];
        }
        wraparound(vString); //wraparound
        strfind(vString, row, 'V');
        row++;
        strReset(vString, MAX_DIM_SIZE * 2 + 1); //added for wraparound
    }
}

void parseDiagonal() {
    char vString[MAX_DIM_SIZE * 2 + 1];
    strReset(vString, MAX_DIM_SIZE * 2 + 1);
    int j;
    int k;
    int i;
    int helper_idx;
    int grid_idx = 0;
    for (j = size[1] - 1; j > -1; j--) {
        strReset(vString, MAX_DIM_SIZE * 2 + 1);
        helper_idx = 0;
        int row = 0;
        int col = 0;
        for (k = 0; k < size[0]; k++) {
            if ((j + k) < size[1]) {
                if (helper_idx == 0) {
                    row = k;
                    col = j + k;
                }
                grid_idx = k * (size[1] + 1) + j + k;
                vString[helper_idx] = grid[grid_idx];
                helper_idx++;

            } else {
                break;
            }
        }
        diagonal = col;
        wraparound(vString); //wraparound
        strfind(vString, row, 'D');
    }
    for (i = 1; i < size[0]; i++) {
        k = 0;
        strReset(vString, MAX_DIM_SIZE * 2 + 1);
        helper_idx = 0;
        int row = 0;
        int col = 0;
        for (j = i; j < size[0]; j++) {
            if (k < size[1]) {
                if (helper_idx == 0) {
                    row = j;
                    col = k;
                }
                grid_idx = k + (size[1] + 1) * j;
                vString[helper_idx] = grid[grid_idx];
                helper_idx++;
            }
            k++;
        }
        diagonal = col;
        wraparound(vString); //wraparound
        strfind(vString, row, 'D');
    }
}

//---------------------------------------------------------------------------
// MAIN function
//---------------------------------------------------------------------------

int main(void) {

    /////////////Reading dictionary and grid files//////////////
    ///////////////Please DO NOT touch this part/////////////////
    int c_input;
    int dict_idx = 0;
    int start_idx = 0;
    int idx = 0;


    // open grid file
    FILE *grid_file = fopen(grid_file_name, "r");
    // open dictionary file
    FILE *dictionary_file = fopen(dictionary_file_name, "r");

    // if opening the grid file failed
    if (grid_file == NULL) {
        print_string("Error in opening grid file.\n");
        return -1;
    }

    // if opening the dictionary file failed
    if (dictionary_file == NULL) {
        print_string("Error in opening dictionary file.\n");
        return -1;
    }
    // reading the grid file
    do {
        c_input = fgetc(grid_file);
        // indicates the the of file
        if (feof(grid_file)) {
            grid[idx] = '\0';
            break;
        }
        grid[idx] = c_input;
        idx += 1;

    } while (1);

    // closing the grid file
    fclose(grid_file);
    idx = 0;

    // reading the dictionary file
    do {
        c_input = fgetc(dictionary_file);
        // indicates the end of file
        if (feof(dictionary_file)) {
            dictionary[idx] = '\0';
            break;
        }
        dictionary[idx] = c_input;
        idx += 1;
    } while (1);

    // closing the dictionary file
    fclose(dictionary_file);
    //////////////////////////End of reading////////////////////////
    ///////////////You can add your code here!//////////////////////
    idx = 0;
    do {
        c_input = dictionary[idx];
        if (c_input == '\0') {
            break;
        }
        if (c_input == '\n') {
            dictionary_idx[dict_idx++] = start_idx;
            start_idx = idx + 1;
        }
        idx += 1;
    } while (1);

    array_init(size);
    dict_num_words = dict_idx;
    parseHorizontal();
    parseVertical(size);
    parseDiagonal();
    if (flag != 1) {
        print_string("-1\n");
    }
    return 0;
}
