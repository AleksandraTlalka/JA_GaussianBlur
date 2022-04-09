using System;
using System.Drawing;
using System.IO;
using System.Windows.Media.Imaging;
using System.Drawing.Imaging;
using CSLib;
using System.Diagnostics;



namespace JA_Filtr_Gaussa
{
    unsafe class MainClass
    {
#if DEBUG
        [System.Runtime.InteropServices.DllImport(@"C:\Users\Ola\source\repos\JA_Filtr_Gaussa\x64\Debug\AsmLib.dll")]
#else
        [System.Runtime.InteropServices.DllImport(@"C:\Users\Ola\source\repos\JA_Filtr_Gaussa\x64\Release\AsmLib.dll")]
#endif
        //private unsafe static extern int MyProc1(byte* input, byte* output, int width, int height);
        //Metoda nakłada filtr uśredniający(z maska 3x3) na obraz.
        //Dane wejsciowe:
        //input - tablica wejsciowa
        //output - tablica wyjsciowa
        //width - szerokosc obrazu w pixelach
        //height - wysokosc obrazu w pixelach
        unsafe static extern int MyProc1(byte* input, byte* output, int width, int height);
        //static extern int MyProc1(int a, int b);


        private BitmapData? imageData;

        private Bitmap? image;

        //Tablica jednowymiarowa przetrzymujaca informacje o pixelach(3 kolory-RGB) obrazu
        public byte* data;

        //Szerokosc obrazu w pixelach
        public int width;

        //Wysokosc obrazu w pixelach
        public int height;

        //Ilosc pixeli w rzędzie * 3
        public int stride;

        //Dlugosc obrazu w pixelach * 3
        public int length;

        //Sciezka do pliku wejsciowego
        string inputDirectory;

        //Klasa z zewnetrznej DLL. Posiada filtr usredniajacy
        private CS CSFilter;

        //Zmienna przechowuje czas wykonywania algorytmu
        private TimeSpan time;

        //Konstruktor
        public MainClass()
        {
            CSFilter = new CSLib.CS();
        }

        //Zaladowanie obrazu z danego linku do zmiennych
        //Metoda zwraca BitmapSource.
        //Pozwala wyswietlic obraz w MainWindow.
        public BitmapSource loadImageFromFile(string directory)
        {
            if (File.Exists(directory))
            {
                inputDirectory = directory;
                MemoryStream imageStream = new MemoryStream();
                FileStream fileStream = File.OpenRead(directory);
                fileStream.CopyTo(imageStream);
                fileStream.Close();
                fileStream.Dispose();

                image = new Bitmap(imageStream);
                imageStream.Close();
                imageStream.Dispose();
                imageStream = null;

                //Jesli format inny niz 24 rzucam wyjatek
                if (image.PixelFormat != System.Drawing.Imaging.PixelFormat.Format24bppRgb)
                {
                    image.Dispose();
                    image = null;
                    throw new ArgumentException("Ten format nie jest wspierany");
                }
                lockImageBits();
                dataToByteArray();
                unlockImageBits();
                return getBitMapSource();
            }
            else
            {
                throw new FileNotFoundException("Nie znaleziono obrazu");
            }
        }

        //Metoda zwraca BitmapSource.
        //Pozwala wyswietlic obraz w MainWindow.
        public BitmapSource getBitMapSource()
        {
            lockImageBits();
            BitmapSource source = BitmapSource.Create(
                image.Width,
                image.Height,
                image.HorizontalResolution,
                image.VerticalResolution,
                System.Windows.Media.PixelFormats.Bgr24,
                null,
                imageData.Scan0,
                imageData.Stride * imageData.Height,
                imageData.Stride
                );
            unlockImageBits();
            return source;
        }

        //Zabklokowanie prostokatnego ksztaltu bitmapy.
        //Pozwala to na utworzenie bufferu do odczytu lub zapisu pixeli.
        private void lockImageBits()
        {
            imageData = image.LockBits(new Rectangle(0, 0, image.Width, image.Height), System.Drawing.Imaging.ImageLockMode.ReadWrite, image.PixelFormat);
        }

        //Odblokowanie wczesniej zablokowanego prostokatnego ksztaltu bitmapy
        private void unlockImageBits()
        {
            if (imageData != null)
            {
                if (image != null)
                {
                    image.UnlockBits(imageData);
                }
                imageData = null;
            }
        }

        //Przekonwertowanie obrazu na tablice jednowymiarowa zawierajaca informacje o pixelach w formacie RGBRGBRGB...
        private void dataToByteArray()
        {
            width = imageData.Width;
            height = imageData.Height;
            stride = imageData.Stride;
            length = stride * height;
            data = (byte*)imageData.Scan0.ToPointer();
        }

        //Zapisanie obrazu do pliku.
        public void SaveFile()
        {
            string outputDirectory = inputDirectory.Replace(".bmp", "-filered.bmp");
            using (FileStream outStream = File.Open(outputDirectory, FileMode.OpenOrCreate))
            {
                image.Save(outStream, image.RawFormat);
            }
        }

        //Zwraca czas wykonywania algorytmu nakładania filtru uśredniającego w formacie tekstowym
        public String getTime()
        {
            return time.ToString(@"mm\:ss\.fffffff");
        }

        public double[,] GaussianBlurKernelForCS(int lenght, double weight)
        {
            double[,] kernel = new double[lenght, lenght];
            double kernelSum = 0;
            int foff = (lenght - 1) / 2;
            double distance = 0;
            double constant = 1d / (2 * Math.PI * weight * weight);
            for (int y = -foff; y <= foff; y++)
            {
                for (int x = -foff; x <= foff; x++)
                {
                    distance = ((y * y) + (x * x)) / (2 * weight * weight);
                    kernel[y + foff, x + foff] = constant * Math.Exp(-distance);
                    kernelSum += kernel[y + foff, x + foff];
                }
            }
            for (int y = 0; y < lenght; y++)
            {
                for (int x = 0; x < lenght; x++)
                {
                    kernel[y, x] = kernel[y, x] * 1d / kernelSum;
                }
            }
            return kernel;
        }

        //Metoda nakłada filtr uśredniający na obraz oraz zapisuje czas wykonywania algorytmu nakładania filtru.
        //isCSharp - jesli true: nakładanie filtru realizowanie jest w C#. jesli false - nakładanie filtru realizowanie jest w asm
        public void applyFilter(bool isCSharp)
        {
            byte[] resultArray = new byte[stride * height]; //Utworzenie tablicy wynikowej o dlugosci rownej dlugosci tablicy wejsciowej
            fixed (byte* result = resultArray)
            {
                Stopwatch timer = new Stopwatch();  //Inicjalizacja timera do zliczania czasu wykonania algortymu
                if (isCSharp)
                {
                    double[,] kernel = GaussianBlurKernelForCS(3, 1);
                    //Wykonanie algorytmu nakładającego filtr w C# oraz zliczanie czasu wykonywania.
                    timer.Start();
                    CSFilter.BlurCS(data, result, width, height, kernel);
                    timer.Stop();
                }
                else
                {
                    //Wykonanie algorytmu nakładającego filtr w asm oraz zliczanie czasu wykonywania.
                    timer.Start();
                    MyProc1(data, result, width, height);
                    timer.Stop();
                }
                time = timer.Elapsed;   //Przypisanie obliczonego czasu do zmiennej time

                //Przypisanie tablicy wynikowej do tablicy wejsciowej
                for (int i = 1; i < height - 1; i++)
                {
                    for (int j = 1; j < width - 1; j++)
                    {
                        int pixelPosition = j * 3 + i * stride;
                        data[pixelPosition] = resultArray[pixelPosition];
                        data[pixelPosition + 1] = resultArray[pixelPosition + 1];
                        data[pixelPosition + 2] = resultArray[pixelPosition + 2];
                    }
                }
            }
        }

    }
}


