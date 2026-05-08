%{
#include <string>
#include "parser.hpp"
%}

%option noyywrap

%%

[A-Ga-g]      { yylval.note_name = new std::string(yytext); return NOTE; }
"^"           { return DIEZ; }
"_"           { return BEMOL; }
"'"           { return OCTAVA_SUS; }
","           { return OCTAVA_JOS; }
[0-9]+        { yylval.duration_val = std::stoi(yytext); return DURATION; }
"/"           { return SLASH; }
[ \t\r\n]+    ; /* ignorăm */
.             { printf("Eroare: '%s'\n", yytext); }

%%