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



import SwiftUI
 
 

struct ContentView: View {
    
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
    
    @State private var replaceStrLs = [["\n",""],["\\",""]]
    
    @State private var cpBtnTitle = "Copy Result"
    
  
    
    var body: some View {
        ScrollView {
            VStack {
                HStack{
                    
                    LabeledContent {
                        TextField(text: $spliterTeStr) {
                            Text("")
                        }
                        .frame(maxWidth: 32)
                        .disabled(isNewLineForSeparator)
                        .onChange(of: spliterTeStr) { _, str in
                            spliterStr  = str
                            if spliterStr.isEmpty {
                                spliterStr = " "
                            }
                            handleSrcStr(srcTeStr)
                        }
                    } label: {
                        Text("Custom Separator")
                    }
                    
                    Toggle(isOn: $isNewLineForSeparator)
                    {
                        Text("'\\n'(new line) for Separator")
                    }
                       .toggleStyle(.checkbox)
                       .onChange(of: isNewLineForSeparator) { _, b in
                           
                           if b {
                               spliterStr = "\n"
                           }else {
                               spliterStr = spliterTeStr
                               if spliterStr.isEmpty { spliterStr = " "}
                           }
                           handleSrcStr(srcTeStr)
                       }
                    
                    Spacer()

                }
                
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
                    Text("Orignal String")
                }
            
                    
                HStack{
                    LabeledContent {
                        TextField(text: $prefixStr) {
                            Text("")
                               
                        } .onChange(of: prefixStr) { _, _ in
                            handleSrcStr(srcTeStr)
                        }
                    } label: {
                        Text("Prefix:")
                    }
                    
                    
                    LabeledContent {
                        TextField(text: $suffixStr) {
                            Text("")
                        }.onChange(of: suffixStr) { _, _ in
                            handleSrcStr(srcTeStr)
                        }
                    } label: {
                        Text("Suffix:")
                    }

                }
                
                Divider()
                Text("We only have permission in ~/Downloads folder, so move files(folders) here before coping....")
                
                HStack {
                   Text("Source Folder:")
                    Text(srcFolderPath).frame(maxWidth: .infinity, alignment: .leading )
                         
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
                   Text("Distance Folder:")
                    Text (dstFolderPath ).frame(maxWidth: .infinity, alignment: .leading )
                        
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
                        Task {
                            await  MainActor.run {
                                   doCopyFiles(srcTeStr)
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.brown)
                    .disabled( srcFolderPath.isEmpty || dstFolderPath.isEmpty || srcFolderPath == dstFolderPath  )
                    
                    Spacer()
                    
                    Button(cpBtnTitle){
                        let pb = NSPasteboard.general
                        pb.declareTypes([.string], owner: nil)
                        pb.setString(rslTeStr, forType: .string)
                        
                        cpBtnTitle = "copied!!"
                        
                        Task{
                          try await   Task.sleep(nanoseconds:2000_000_000)
                            cpBtnTitle = "Copy Result"
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
            Task {
                try await Task.sleep(nanoseconds: 600_000_000)
                    dstFolderPath = URL.userHomePath + "/Downloads/"
                    srcFolderPath = URL.userHomePath + "/Downloads/"
            }
        }
        
        
    }
    
    func handleSrcStr (_ str0 : String) {
        
        var str = str0
        
        replaceStrLs.forEach{  strLs  in
            if strLs.first?.isEmpty != true {
                str.replace(strLs.first!, with: strLs.last!)
            }
        }
        
        let rslStr =   str.split(separator: spliterStr, omittingEmptySubsequences: true).filter{ !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }  .map { s in
            
           prefixStr +   s + suffixStr
        }
        
        rslTeStr = rslStr.joined(separator: "\n")
        
    }
    
    func doCopyFiles(_ str : String)   {
        let rslStr =   str.split(separator: spliterStr, omittingEmptySubsequences: true)
        
        let srcPathnameLs = rslStr.map { srcFolderPath + $0   }
        
        rslTeStr = ""
         
        for i in srcPathnameLs.enumerated() {
            
            var hdFn = ""
            let tmpUrl = URL(string: i.element)
         
                if let fn = tmpUrl?.deletingPathExtension().absoluteString {
                    hdFn = fn + ".h"
                    
                    if  !FileManager.default.fileExists(atPath: URL.init(string:  hdFn)!.absoluteString) {
                        hdFn = ""
                }
            }
            
            if !isCpHeader {
                hdFn = ""
            }
           
            
            var cmdStr = "cp \(isForceOverride ? "-f " : "")\(i.element) \(dstFolderPath)"
            if !hdFn.isEmpty {
                cmdStr.append(";cp \(isForceOverride ? "-f " : "")\(hdFn) \(dstFolderPath)")
            }
         //  print(cmdStr)
            
            rslTeStr.append(cmdStr)
            rslTeStr.append("\n")
              
            let task = Process()
            task.launchPath = "/bin/zsh"
             task.arguments = ["-c",  cmdStr]
 
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe
            task.launch()
            
              if let  data = try?  pipe.fileHandleForReading.readToEnd(){
                if let rslStr0 = String(data: data , encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                         rslTeStr.append(rslStr0)
                        rslTeStr.append("\n\n")
                }
            }
        }
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
