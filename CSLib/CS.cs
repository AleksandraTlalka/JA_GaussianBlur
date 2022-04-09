using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;

namespace CSLib
{
    public unsafe class CS
    {
        //Metoda nakłada rozmycie Gaussa na obraz.
        //Dane wejsciowe:
        //input - tablica wejsciowa
        //output - tablica wyjsciowa
        //imageWidth - szerokosc obrazu w pixelach
        //imageHeight - wysokosc obrazu w pixelach
        //kernel - tablica jądra filtru
        unsafe public void BlurCS(byte* input, byte* output, int imageWidth, int imageHeight, double[,] kernel)
        {
            int stride = imageWidth * 3; // ilość pixeli w rzędzie
            double[] rgb = new double[3]; // tablica trójki RGB
            int kernelBorder = (kernel.GetLength(0) - 1) / 2; // liczba pixeli od środka jądra do jego granicy
            int pixelPosition = 0; //pozycja środka jądra filtru
            int kpixel = 0; 
            for (int y = 1; y < imageHeight - kernelBorder; y++) //Iterowanie po wysokosci obrazu
            {
                for (int x = 1; x < imageWidth - kernelBorder; x++) //Iterowanie po szerokości obrazu
                {
                    rgb[0] = 0.0; //zerowanie wartości tablicy
                    rgb[1] = 0.0;
                    rgb[2] = 0.0;

                    pixelPosition = y * stride + x * 3;
                    for (int fy = -kernelBorder; fy < kernelBorder + 1; fy++) //Iterowanie po wysokosci jądra
                    {
                        for (int fx = -kernelBorder; fx < kernelBorder + 1; fx++) //Iterowanie po szerokości jądra
                        {
                            kpixel = pixelPosition + fy * stride + fx * 3;
                            rgb[0] += (double)(input[kpixel]) * kernel[fy + kernelBorder, fx + kernelBorder]; //Sunowanie wartości Red pixeli z określioną wagą
                            rgb[1] += (double)(input[kpixel + 1]) * kernel[fy + kernelBorder, fx + kernelBorder]; //Sunowanie wartości Green pixeli z określioną wagą
                            rgb[2] += (double)(input[kpixel + 2]) * kernel[fy + kernelBorder, fx + kernelBorder]; //Sunowanie wartości Blue pixeli z określioną wagą
                        }
                    }
                    output[pixelPosition + 0] = (byte)rgb[0]; //Przypisanie obliczonych wartości do pixela w tablicy wyjsciowej.
                    output[pixelPosition + 1] = (byte)rgb[1];
                    output[pixelPosition + 2] = (byte)rgb[2];
                }
            }
        }
    }
}
