#include <stdio.h>
#include <stdlib.h>
#include <curl/curl.h>
#include <ctype.h>

void automatoUrl(char c) {
	static char state = 0;
	static char url[512];
	static int pos = 0;

	url[pos++] = c;

	switch (state) {
	case 0:
		pos = 1;
		url[0] = c;

		if (c == 'w') 
			state = 1;
		else
			state = 0;
	break;
	case 1:
		if (c == '.')
			state = 2;
		else if (!(isalnum(c)))
			state = 0;
	break;
	case 2:
		if (isalnum(c))
			state = 3;
		else
			state = 0;
	break;
	case 3:
		if (isalnum(c))
			state = 3;
		else if (c == '/' || c == '.')
			state = 2;
		else
		{
			url[pos - 1] = 0;
			printf("Achei a URL: %s\n", url);
			state = 0;
		}
	break;
	}
}

void automatoEmail(char c) {
	static char state = 0;
	static char email[512];
	static int pos = 0;

	email[pos++] = c;

	switch (state) {
	case 0:
		pos = 1;
		email[0] = c;

		if (isalnum(c)) 
			state = 1;
		else
			state = 0;
	break;
	case 1:
		if (c == '@')
			state = 2;
		else if (!(isalnum(c) || c == '.' || c == '_'))
			state = 0;
	break;
	case 2:
		if (isalnum(c))
			state = 3;
		else
			state = 0;
	break;
	case 3:
		if (isalnum(c))
			state = 3;
		else if (c == '.')
			state = 2;
		else
		{
			email[pos - 1] = 0;
			printf("Achei e-mail: %s\n", email);
			state = 0;
		}
	break;
	}
}

size_t process_data(char *data, size_t a, size_t n, void *b) {
	
	for (int i = 0; i < n; i++) {
		automatoEmail(data[i]);
	}

	for (int i = 0; i < n; i++) {
		automatoUrl(data[i]);
	}

	return n;
}

int main(int argc, char *argv[]) {

	CURL *curl;
	CURLcode res;

	curl = curl_easy_init();
	if (!curl)
		exit(1);

	curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, process_data);
	curl_easy_setopt(curl, CURLOPT_URL, argv[1]);
	curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);

	res = curl_easy_perform(curl);
	if (res != CURLE_OK)
	{
		fprintf(stderr, "something bad: %s\n", curl_easy_strerror(res));
		exit(1);
	}
	curl_easy_cleanup(curl);
}

// Pesquisa no site: computacao.jatai.ufg.br/n/36222-corpo-docente
// Retorno:
	//Achei e-mail: anainocencio@ufg.br
	//Achei e-mail: ana_vilela@ufg.br
	//Achei e-mail: bispojr@ufg.br
	//Achei e-mail: flavio@ufg.br
	//Achei e-mail: franciny@ufg.br
	//Achei e-mail: italo@ufg.br
	//Achei e-mail: jeferreirajf@ufg.br
	//Achei e-mail: joslaine@ufg.br
	//Achei e-mail: msfreitas@ufg.br
	//Achei e-mail: marciocomp@ufg.br
	//Achei e-mail: marcos_ribeiro@ufg.br
	//Achei e-mail: thborges@ufg.br
	