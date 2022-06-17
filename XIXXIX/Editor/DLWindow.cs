#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Net;
using System;
using Microsoft.Win32;
using System.IO;

namespace XIXXIX
{
    public class DLWindow : EditorWindow
    {
        public string Version = "1";
        public string LatestVersion = "0";
        public string FileName = "XIXXIX-Shader";
        public string InstallPath { get; set; }

        [MenuItem("Tools/XIXXIX-Downloader")]
        static void Init()
        {
            DLWindow window = (DLWindow)EditorWindow.GetWindow(typeof(DLWindow));
            window.Show();
            window.title = "Downloader";
        }

        void OnEnable()
        {
            WebClient webClient = new WebClient();
            LatestVersion = webClient.DownloadString("https://XIXXIX-Shader.not90hz.repl.co");
            InstallPath = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData).Replace("Roaming", "LocalLow") + "/XIXXIX/";
            if(!Directory.Exists(InstallPath)) Directory.CreateDirectory(InstallPath);

        }

        void OnGUI()
        {
            EditorGUILayout.BeginVertical(GUI.skin.box);
            EditorGUILayout.LabelField("Version:", Version + " - " + LatestVersion);
            if (GUILayout.Button("Download")) Download(); 
            EditorGUILayout.EndVertical();
        }

        void Download()
        {
            WebClient webClient = new WebClient();
            Application.OpenURL("https://github.com/not90Hz/XIXXIX-Shader/releases/latest/download/" + string.Format("{0}.unitypackage", FileName));
            //webClient.DownloadFile("https://github.com/not90Hz/XIXXIX-Shader/releases/latest/download/" + string.Format("{0}.unitypackage", FileName), string.Format("{0}.unitypackage", FileName));
            string downloads = Registry.GetValue(@"HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders", "{374DE290-123F-4565-9164-39C4925E467B}", String.Empty).ToString();
            if (File.Exists(downloads + string.Format("/{0}.unitypackage", FileName)))
            {
                if (File.Exists(string.Format("{0}{1}.unitypackage", InstallPath, FileName))) File.Delete(string.Format("{0}{1}.unitypackage", InstallPath, FileName));
                File.Move(downloads + string.Format("/{0}.unitypackage", FileName), string.Format("{0}{1}.unitypackage", InstallPath, FileName));
                AssetDatabase.ImportPackage(string.Format("{0}{1}.unitypackage", InstallPath, FileName), true);
            }
        }
    }
}
#endif