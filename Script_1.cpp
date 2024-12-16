#include <iostream>
using namespace std;

// Função recursiva para resolver as Torres de Hanói
void torreDeHanoi(int n, char origem, char auxiliar, char destino) {
    // Caso base: Se houver apenas um disco, mova-o diretamente
    if (n == 1) {
        cout << "Mover disco 1 de " << origem << " para " << destino << endl;
        return;
    }

    // Mover n-1 discos de 'origem' para 'auxiliar', usando 'destino' como auxiliar
    torreDeHanoi(n - 1, origem, destino, auxiliar);

    // Mover o disco maior (n) de 'origem' para 'destino'
    cout << "Mover disco " << n << " de " << origem << " para " << destino << endl;

    // Mover os n-1 discos de 'auxiliar' para 'destino', usando 'origem' como auxiliar
    torreDeHanoi(n - 1, auxiliar, origem, destino);
}

int main() {
    int n;  // Número de discos
    cout << "Digite o número de discos: ";
    cin >> n;

    // Origem = A, Auxiliar = B, Destino = C
    torreDeHanoi(n, 'A', 'B', 'C');

    return 0;
}
