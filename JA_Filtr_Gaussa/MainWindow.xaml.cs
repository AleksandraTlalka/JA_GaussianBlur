using System;
using System.Windows;
using System.Windows.Media;
using Microsoft.Win32;

namespace JA_Filtr_Gaussa
{
    public partial class MainWindow : Window
    {
        //Klasa odpowiedzialan za przetrzymywanie informacji na temat obrazu
        //oraz stosowanie filtru na obrazie.
        MainClass imageData;

        //Konstruktor
        public MainWindow()
        {
            InitializeComponent();
            imageData = new MainClass();
        }

        //Reakcja na nacisniecie przycisku rozpoczynajacego nalozenie filtru na obraz
        private void buttonFilter_Click(object sender, RoutedEventArgs e)
        {
            string language;
            if (radioButtonCS.IsChecked == true) {
                imageData.applyFilter(true);
                language = " dla C#: ";
            }
            else {
                imageData.applyFilter(false);
                language = " dla ASM: ";
            }
            imageData.SaveFile();
            imageAfter.Source = imageData.getBitMapSource();
            labelTime.Content = "Czas wykonywania" + language + imageData.getTime();
        }

        //Przycisk odpowiedzialny za załadowanie obrazu do programu
        private void buttonLoad_Click(object sender, RoutedEventArgs e)
        {

            OpenFileDialog openFileWindow = new OpenFileDialog();
            openFileWindow.Title = "Wybierz obraz do przefiltrowania";
            openFileWindow.Filter = "Wspierane formaty|*.bmp|" +
              "BMP (*.bmp)|*.bmp";
            labelLoadImage.Content = "Ładowanie obrazu...";
            labelLoadImage.Foreground = Brushes.White;
            if (openFileWindow.ShowDialog() == true)
            {
                String directory = openFileWindow.FileName;
                try
                {
                    imageBefore.Source = imageData.loadImageFromFile(directory);
                    imageAfter.Source = null;
                    labelLoadImage.Content = "Załadowano obraz";
                    buttonRun.IsEnabled = true;
                }
                catch (Exception exc)
                {
                    labelLoadImage.Content = exc.Message;
                    imageBefore.Source = null;
                    imageAfter.Source = null;
                    buttonRun.IsEnabled = false;
                }
            }
            else
            {
                labelLoadImage.Content = "Nie załadowano obrazu!";
                imageBefore.Source = null;
                imageAfter.Source = null;
                buttonRun.IsEnabled = false;
            }
        }
    }
}
