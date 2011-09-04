using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Runtime.InteropServices;

namespace WpfDmx
{
    /// <summary>
    /// Logique d'interaction pour MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        [DllImport("k8062d.dll", CharSet = CharSet.Unicode)]
        public static extern int StartDevice();
        [DllImport("k8062d.dll", CharSet = CharSet.Unicode)]
        public static extern int SetData(int channel, int data);
        [DllImport("k8062d.dll", CharSet = CharSet.Unicode)]
        public static extern int StopDevice();
        private static int StartAddress = 1;
        public MainWindow()
        {
            InitializeComponent();
            StartDevice();

        }

        private void scrollBar1_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            int val = (int)(255 - scrollBar1.Value * 255);
            label1.Content = val;
            SetData(StartAddress, val );
        }

        private void scrollBar2_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            int val = (int)(255 - scrollBar2.Value * 255);
            label2.Content = val;
            SetData(StartAddress+1, val);

        }

        private void scrollBar3_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            int val = (int)(255 - scrollBar3.Value * 255);
            label3.Content = val;
            SetData(StartAddress+2, val);

        }

        private void scrollBar4_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            int val = (int)(255 - scrollBar4.Value * 255);
            label4.Content = val;
            SetData(StartAddress+3, val);

        }

        private void Window_Closed(object sender, EventArgs e)
        {
            StopDevice();
        }
    }
}
