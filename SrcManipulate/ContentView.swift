//
//  ContentView.swift
//  SrcManipulate
//
//  Created by thor on 6/3/24
//  
//
//  Email: toot@tootzoe.com  Tel: +855 69325538 
//
//


import Foundation
import SwiftUI
 
 

struct ContentView: View {
    
    static var initReplaingStrLs : [[String]] {
        [["\n",""],["\r",""],["\t",""],["\\",""]]
    }
    
    @State private var srcTeStr :String  = ""
    @State private var rslTeStr :String  = ""
    
    @State private var spliterStr = " "
    @State private var spliterTeStr = " "
    
    
    @State private var srcFolderPath :String  = ""
    // only this folder path we have permission to write files
     @State private var dstFolderPath :String  = ""
     
    
    
    @State private var prefixStr = ""
    @State private var suffixStr = " \\"
    
    @State private var isCpHeader = true
    @State private var isForceOverride = true
    @State private var isNewLineForSeparator = false
    
    @State private var replaceStrLs = initReplaingStrLs // [["\n",""],["\r",""],["\t",""],["\\",""]]
    
    @State private var cpBtnTitle = "Copy Result String"
    
    enum TSpliterChar : String , CaseIterable , Identifiable {
        var id : String { rawValue }
        
    case space = " "
    case tab   = "\t"
    case nextline   = "\n"
    case enter   = "\r"
    case customer = ""
         
    }
    
    @State private var currSC  = TSpliterChar.space
  
    
    var body: some View {
        ScrollView {
            VStack {
               
                
                GroupBox {
                    HStack {
                        TextEditor(text: $srcTeStr)
                            .frame(height: 200)
                            .onChange(of: srcTeStr) { _ , newValue in 
                                handleSrcStr(newValue)
                        }
                        
                        VStack {
                            Button {
                                srcTeStr = ""
                                } label: {
                                    Label(
                                        title: { Text("clean")  },
                                        icon: { Image(systemName: "eraser.line.dashed.fill") }
                                    )
                                    .frame(width: 50,height: 24)
                                    .labelStyle(.iconOnly)
                            }.buttonStyle(.borderedProminent)
                            
                            Button {
                                if  let str = NSPasteboard.general.pasteboardItems?.first?.string(forType: .string)
                                {
                                   srcTeStr = str
                                 }
                                } label: {
                                    Label(
                                        title: { Text("replace with clipboard")  },
                                        icon: { Image(systemName: "doc.on.clipboard.fill") }
                                    )
                                    .frame(width: 50,height: 24)
                                    .labelStyle(.iconOnly)
                            }.buttonStyle(.borderedProminent)
                                .tint(.cyan)
                            
                        }
                    }
                } label: {
                    Text("Original String")
                    //  Text("Original source file names")Text("Cleaned file names")
                }
                
                HStack{
                    Picker("String Spliter" , selection: $currSC){
                        ForEach(TSpliterChar.allCases) { c in
                            
                                Text(String(describing: c)   )
                                .tag(c)
                            
                        }
                    }
                    .frame(maxWidth: 500)
                    .pickerStyle(.segmented)
                        .onChange(of: currSC) { ochar , _ in
                            spliterStr = currSC.rawValue
                            if currSC == .customer {
                                spliterStr = TSpliterChar.space.rawValue
                            }
                            
                         
                            replaceStrLs.removeAll { $0[0] == spliterStr || $0[0].isEmpty  }
                             
                            if !ochar.rawValue.isEmpty {
                                replaceStrLs.append([ochar.rawValue ,""])
                            }
                            
                            handleSrcStr(srcTeStr)
                        }
                    
 
                        TextField(text: $spliterTeStr) {
                            Text("Custom Separator")
                        }
                        .frame(maxWidth: 32)
                        .disabled(currSC != .customer )
                        .onChange(of: spliterTeStr) { _, str in
                            spliterStr  = str
 
                            handleSrcStr(srcTeStr)
                            
                        }
 
                 
        
                    Text("Current Spliter (hex) 0x\(spliterStr.hexStr.uppercased())")
                  
                    
                    
                    
//                    Toggle(isOn: $isNewLineForSeparator)
//                    {
//                        Text("'\\n'(new line) for Separator")
//                    }
//                       .toggleStyle(.checkbox)
//                       .onChange(of: isNewLineForSeparator) { _, b in
//                           print(spliterStr)
////                           if b {
////                               spliterStr = "\n"
////                           }else {
////                               spliterStr = spliterTeStr
////                               if spliterStr.isEmpty { spliterStr = " "}
////                           }
////                           handleSrcStr(srcTeStr)
//                       }
                    
                     
                    
                    
                    Spacer()

                }
            
                    
                HStack{
                    LabeledContent {
                        TextField(text: $prefixStr) {
                            Text("")
                               
                        } .onChange(of: prefixStr) { _, _ in
                            handleSrcStr(srcTeStr)
                        }
                    } label: {
                        Text("Appending Prefix:")
                    }
                    
                    
                    LabeledContent {
                        TextField(text: $suffixStr) {
                            Text("")
                        }.onChange(of: suffixStr) { _, _ in
                            handleSrcStr(srcTeStr)
                        }
                    } label: {
                        Text("Appending Suffix:")
                    }

                }
                
                Divider()
                Text("We only have permission in ~/Downloads folder, so move files(folders) here before coping....")
                
                HStack {
                   
//                    Text(srcFolderPath).frame(maxWidth: .infinity, alignment: .leading )
                    
                    LabeledContent {
                        TextField(text:$srcFolderPath){
                            Text("Copy from Folder:")
                        }
                    } label: {
                        Text("Copy from Folder:")
                    }

                         
                    Button("Select"){
                      let op =  NSOpenPanel()
                        op.directoryURL = NSURL.fileURL(withPath: ".", isDirectory: true)
                       // op.allowedContentTypes = [.text]
                        op.canChooseDirectories = true
                        op.canChooseFiles = false
                        op.begin { (rsl) -> Void in
                            if rsl.rawValue == NSApplication.ModalResponse.OK.rawValue {
                                srcFolderPath = op.url?.path() ?? ""
                                 
                            }
                           
                        }
                    }
                    .buttonStyle(.borderedProminent).tint(.cyan)
                }
                 
                
                HStack {
//                   Text("Distance Folder:")
//                    Text (dstFolderPath ).frame(maxWidth: .infinity, alignment: .leading )
                    
                    LabeledContent {
                        TextField(text:$dstFolderPath){
                            Text("Copy to Folder:")
                        }
                    } label: {
                        Text("Copy to Folder:")
                    }
                    
                        
                    Button("Select"){
                      let op =  NSOpenPanel()
                        op.directoryURL = NSURL.fileURL(withPath: ".", isDirectory: true)
                       // op.allowedContentTypes = [.text]
                        op.canChooseDirectories = true
                        op.canChooseFiles = false
                        op.title = "Select a Distance Folder"
                        op.begin { (rsl) -> Void in
                            if rsl.rawValue == NSApplication.ModalResponse.OK.rawValue {
                                dstFolderPath = op.url?.path() ?? ""
                                 
                            }
                           
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
                

                HStack {
                    
                    Text("Copy files: ")
                   
                    Toggle(isOn: $isCpHeader) 
                    {
                        Text("Copy header file also (if exist)")
                    }
                       .toggleStyle(.checkbox)  
                    
                    Toggle(isOn: $isForceOverride)
                    {
                        Text("Force Override")
                    }
                       .toggleStyle(.checkbox)

                    
                    Button("Do Copy files") {
                        DispatchQueue.global(qos: .default).async {
                            doCopyFiles(rslTeStr)
                        }
                           
                                   
                           
                        
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.brown)
                   // .disabled( srcFolderPath.isEmpty || dstFolderPath.isEmpty || srcFolderPath == dstFolderPath  )
                    
                    Spacer()
                    
                    Button(cpBtnTitle){
                        let pb = NSPasteboard.general
                        pb.declareTypes([.string], owner: nil)
                        pb.setString(rslTeStr, forType: .string)
                        
                        cpBtnTitle = "copied!!"
                        
                        Task{
                          try await   Task.sleep(nanoseconds:2000_000_000)
                            cpBtnTitle = "Copy Result String"
                        }
                        
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                
                HStack {
                    GroupBox {
                           
                            TReplaceStrWid(replaceStrLs: $replaceStrLs)
                                .frame(minWidth: 200,maxWidth: 260, minHeight: 200   )
                                .onChange(of: replaceStrLs) { _, _ in
                                    handleSrcStr(srcTeStr)
                                }
                       
                      
                  } label: {
                      Text("Replacing")
                  }
                    
                    GroupBox {
                        TextEditor(text: $rslTeStr)
                            .frame(height: 200)
                        
                    } label: {
                        Text("Result String")
                    }
                }
           
            }
            .padding()
        }
        .task  {
                    
                    srcFolderPath =   URL.userHomePath
            dstFolderPath =    URL.userHomePath
            
        }
        
        
    }
    
    func handleSrcStr (_ str0 : String) {
        
        var str = str0
        
        replaceStrLs.forEach{  strLs  in
            if let keyStr = strLs.first , keyStr != spliterStr {
                str = str.replacingOccurrences(of: keyStr, with: strLs.last!)
            }
            
//            if strLs.first?.isEmpty != true {
//                str = str.replacingOccurrences(of: strLs.first!, with: strLs.last!)
//            }
        }
        
        let rslStr =   str.split(separator: spliterStr, omittingEmptySubsequences: true).filter{ !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }  .map { s in
            
           prefixStr +   s + suffixStr
        }
        
        rslTeStr = rslStr.joined(separator: "\n")
        
    }
    
    func doCopyFiles(_ str : String)   {
        let rslStr =   str.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\\", with: "").split(separator: "\n")
        
        rslTeStr = ""
       // print(rslStr)
 
        for s in rslStr {
            
            let srcBase = URL.init(filePath: srcFolderPath)
            let dstBase = URL.init(filePath: dstFolderPath)
            let srcFile = srcBase.appendingPathComponent( String(s), conformingTo: .text)
            let dstFile = dstBase.appendingPathComponent( String(s), conformingTo: .text)
              
         
            
                let b =   FileManager.default.fileExists(atPath:  srcFile.path())
                var  hdFn = ""
                if b {
                     createInterPathfolder(dstFile)
                    
                    let fext = srcFile.pathExtension.lowercased()
                    if  isCpHeader &&  (fext == "c" || fext == "cpp") {
                        let u = srcFile.deletingPathExtension().appendingPathExtension("h")
                        if FileManager.default.fileExists(atPath:  u.path()){
                           // print("have header: " , u)
                            hdFn = u.path()
                        }
                    }
                      
                    let dstFolder =  dstFile.deletingLastPathComponent().path()
                    var cmdStr = "cp \(isForceOverride ? "-f " : "")\(srcFile.path()) \(dstFolder)"
                    if !hdFn.isEmpty {
                        cmdStr.append(";cp \(isForceOverride ? "-f " : "")\(hdFn) \(dstFolder)")
                    }
                    
                    var tmpCmdStr = cmdStr + "\n"
                     
                    let task = Process()
                    task.launchPath = "/bin/zsh"
                     task.arguments = ["-c",  cmdStr]
         
                    let pipe = Pipe()
                    task.standardOutput = pipe
                    task.standardError = pipe
                    task.launch()
                    
                      if let  data = try?  pipe.fileHandleForReading.readToEnd(){
                        if let rslStr0 = String(data: data , encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                            tmpCmdStr.append(rslStr0)
                            tmpCmdStr.append("\n\n")
                            
                        }
                    }
                    
                    DispatchQueue.main.async {
                        rslTeStr.append(tmpCmdStr)
                    }
                }
        }
 
    }
    
    
    private func createInterPathfolder(_ dstPathFile: URL) {
        var tmpFUrl = dstPathFile
        tmpFUrl . deleteLastPathComponent()
        // print(tmpFUrl.path())
        
        if !FileManager.default.fileExists(atPath: tmpFUrl.path()) {
            do {
                try   FileManager.default.createDirectory(at:   tmpFUrl  , withIntermediateDirectories: true )
            }catch{
                fatalError(error.localizedDescription)
            }
        }
    }
    
    
}

public extension String {
    var hexStr : String {
        Data(self.utf8).hexDescription
    }
}

public extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}


public extension URL {
    static var userHome : URL   {
        URL(fileURLWithPath: userHomePath, isDirectory: true)
    }
    
    static var userHomePath : String   {
        let pw = getpwuid(getuid())

        if let home = pw?.pointee.pw_dir {
            return FileManager.default.string(withFileSystemRepresentation: home, length: Int(strlen(home)))
        }
        
        fatalError()
    }
}


#Preview {
    ContentView()
         
}
