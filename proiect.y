%{
#include <iostream>
#include <vector>
#include <map>
#include <string>
#include <cmath>
#include <fstream>


const int SAMPLE_RATE = 44100;
const int AMPLITUDE = 12000;
std::vector<int16_t> audioBuffer;


std::map<std::string, double> base_freq = {
    {"C", 261.63}, // Do
    {"D", 293.66}, // Re
    {"E", 329.63}, // Mi
    {"F", 349.23}, // Fa
    {"G", 392.00}, // Sol
    {"A", 440.00}, // La
    {"B", 493.88}  // Si
};


double calculeazaFrecventa(std::string nota, int alteratie, int octava_offset) {
    std::string nota_baza = nota;
    if (islower(nota[0])) {
        nota_baza[0] = toupper(nota[0]);
    }

    double freq = base_freq[nota_baza];

    if (islower(nota[0])) {
        freq *= 2.0;
    }

    if (octava_offset > 0) freq *= std::pow(2.0, octava_offset);
    else if (octava_offset < 0) freq /= std::pow(2.0, std::abs(octava_offset));


    if (alteratie == 1) freq *= std::pow(2.0, 1.0/12.0);       // Diez
    else if (alteratie == -1) freq /= std::pow(2.0, 1.0/12.0); // Bemol

    return freq;
}


void adaugaNotaInBuffer(double freq, double dur_multiplicator) {
    double durata_secunde = dur_multiplicator * 0.5; 
    int nr_esantioane = static_cast<int>(durata_secunde * SAMPLE_RATE);

    for (int i = 0; i < nr_esantioane; ++i) {
        double t = (double)i / SAMPLE_RATE;
        int16_t sample = static_cast<int16_t>(AMPLITUDE * sin(2 * M_PI * freq * t));
        audioBuffer.push_back(sample);
    }
}


void salveazaWav(const std::string& nume_fisier) {
    std::ofstream f(nume_fisier, std::ios::binary);

    int32_t data_size = audioBuffer.size() * sizeof(int16_t);
    int32_t chunk_size = 36 + data_size;
    int16_t audio_format = 1;
    int16_t num_channels = 1;
    int32_t byte_rate = SAMPLE_RATE * num_channels * sizeof(int16_t);
    int16_t block_align = num_channels * sizeof(int16_t);
    int16_t bits_per_sample = 16;

    // Header-ul WAV
    f.write("RIFF", 4);
    f.write(reinterpret_cast<const char*>(&chunk_size), 4);
    f.write("WAVE", 4);
    f.write("fmt ", 4);
    int32_t subchunk1_size = 16;
    f.write(reinterpret_cast<const char*>(&subchunk1_size), 4);
    f.write(reinterpret_cast<const char*>(&audio_format), 2);
    f.write(reinterpret_cast<const char*>(&num_channels), 2);
    f.write(reinterpret_cast<const char*>(&SAMPLE_RATE), 4);
    f.write(reinterpret_cast<const char*>(&byte_rate), 4);
    f.write(reinterpret_cast<const char*>(&block_align), 2);
    f.write(reinterpret_cast<const char*>(&bits_per_sample), 2);
    f.write("data", 4);
    f.write(reinterpret_cast<const char*>(&data_size), 4);


    f.write(reinterpret_cast<const char*>(audioBuffer.data()), data_size);
    f.close();
}


int yylex();
void yyerror(const char *s) { std::cerr << "Eroare: " << s << std::endl; }
%}

%code requires {
    #include <string>
}

%union {
    int duration_val;
    std::string* note_name; 
    double real_val;
}


%token <duration_val> DURATION
%token <note_name> NOTE
%token DIEZ BEMOL OCTAVA_SUS OCTAVA_JOS SLASH

%type <duration_val> semn_alteratie modificare_octava
%type <real_val> modificare_durata

%%


piesa:
      %empty
    | piesa element_muzical
    ;

element_muzical:
    nota_completa { std::cout << "Nota procesata cu succes!\n"; }
    ;

nota_completa:
    semn_alteratie NOTE modificare_octava modificare_durata 
    {
        int alt = $1;
        int oct = $3;
        double dur = $4;
        
        double freq = calculeazaFrecventa(*$2, alt, oct);
        adaugaNotaInBuffer(freq, dur);
        
        std::cout << "Nota: " << *$2 
                  << " | Freq: " << freq << " Hz" 
                  << " | Durata: " << dur << "x unitate" << std::endl;

        delete $2;
    }
    ;

semn_alteratie:
      DIEZ          { $$ = 1; }
    | BEMOL         { $$ = -1; }
    | %empty        { $$ = 0; }
    ;

modificare_octava:
      OCTAVA_SUS    { $$ = 1; }
    | OCTAVA_JOS    { $$ = -1; }
    | %empty        { $$ = 0; }
    ;

modificare_durata:
      DURATION                    { $$ = (double)$1; }
    | SLASH DURATION              { $$ = 1.0 / (double)$2; }
    | DURATION SLASH DURATION     { $$ = (double)$1 / (double)$3; }
    | SLASH                       { $$ = 0.5; }
    | %empty                      { $$ = 1.0; }
    ;

%%

int main() {
    std::cout << "Incepe compilarea muzicala..." << std::endl;
    yyparse();
    
    if (!audioBuffer.empty()) {
        salveazaWav("iesire.wav");
        std::cout << "Gata! Fișierul 'iesire.wav' a fost generat." << std::endl;
    } else {
        std::cout << "Nu am gasit note valide." << std::endl;
    }
    return 0;
}