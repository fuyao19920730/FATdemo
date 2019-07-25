using System.IO;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;
using UnityEngine;


public class BuildXCodeConfig
{
    [PostProcessBuild(999)]
    public static void OnPostprocessBuild(BuildTarget bulidTarget, string path)
    {
        Debug.Log("iOS 打包回调配置");
        if (bulidTarget != BuildTarget.iOS) return;

        //设置Tartget-General-siging
        //PlayerSettings.iOS.appleDeveloperTeamID = "9H9Y63L3Q6";
        //PlayerSettings.iOS.appleEnableAutomaticSigning = true;

        //基础配置，得到工程的targetGuid 
        string projectPath = PBXProject.GetPBXProjectPath(path);
        PBXProject project = new PBXProject();
        string fileText = File.ReadAllText(projectPath);
        project.ReadFromString((fileText));

        string targetGuid = project.TargetGuidByName(PBXProject.GetUnityTargetName());


        //capability设置
        //var capManager = new ProjectCapabilityManager(projectPath, "skiGame.entitlements", PBXProject.GetUnityTargetName());
        //SetCapabilities(capManager);

        //BuildSetting
        //SetBuildSetting(project, targetGuid, projectPath);

        //framework
        AddFramework(project, targetGuid, projectPath);

        //plist文件
        AddPlist(path);



    }

    private static void SetCapabilities(ProjectCapabilityManager manager)
    {

    }

    private static void SetBuildSetting(PBXProject project, string targetGuid, string projectPath)
    {
        project.SetBuildProperty(targetGuid, "ENABLE_BITCODE", "NO");
        project.AddBuildProperty(targetGuid, "OTHER_LDFLAGS", "-ObjC");

        // Save the changes to Xcode project file.
        project.WriteToFile(projectPath);
    }

    private static void AddFramework(PBXProject project, string targetGuid, string projectPath)
    {

        //BU 依赖库
        string[] BUSDKAppends = {
            "CoreTelephony.framework",
            "AdSupport.framework",
         };
        foreach (string str in BUSDKAppends)
        {
            Debug.Log("unity adding " + str + " to Xcode ");
            project.AddFrameworkToProject(targetGuid, str, true);
            Debug.Log("unity adding " + str + "to Xcode finishe");

        }

        // Save the changes to Xcode project file.
        project.WriteToFile(projectPath);

    }


    static void AddPlist(string projPath)
    {
        string plistPath = projPath + "/Info.plist";
        PlistDocument plist = new PlistDocument();
        plist.ReadFromString(File.ReadAllText(plistPath));

        PlistElementDict rootDic = plist.root;

        //不设置这项，提交时会显示缺少合规证明
        rootDic.SetBoolean("ITSAppUsesNonExemptEncryption", false);
        rootDic.SetString("NSCameraUsageDescription", "$(PRODUCT_NAME)想用下你的相机啦"); //相机
        rootDic.SetString("NSMicrophoneUsageDescription", "$(PRODUCT_NAME)想要使用麦克风");//mic
        rootDic.SetString("NSPhotoLibraryUsageDescription", "$(PRODUCT_NAME)想要访问相册");
        rootDic.SetString("NSLocationWhenInUseUsageDescription", "$(PRODUCT_NAME)需要获取您的当前位置");


        PlistElementDict arbitraryLoad = rootDic.CreateDict("NSAppTransportSecurity");
        arbitraryLoad.SetBoolean("NSAllowsArbitraryLoads", true);
        File.WriteAllText(plistPath, plist.WriteToString());
    }
}