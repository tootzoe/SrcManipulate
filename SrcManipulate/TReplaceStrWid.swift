//
//  TReplaceStrWid.swift
//  SrcManipulate
//
//  Created by thor on 7/3/24
//  
//
//  Email: toot@tootzoe.com  Tel: +855 69325538 
//
//



import SwiftUI

struct TReplaceStrWid: View {
    @Binding var replaceStrLs : [[String]]
    
    
    
    var body: some View {
        VStack {
            
            if replaceStrLs.isEmpty {
                Text("Click Add button add String source for replacing!")
            } else {
                
                ScrollView {
                    ForEach( replaceStrLs.indices , id: \.self   ){ idx in
                        // print(it)
                        HStack {
                            Button {
                                replaceStrLs.remove(at: idx)
                            } label: {
                                Label(
                                    title: { Text("minus")  },
                                    icon: { Image(systemName: "minus.circle.fill") }
                                ).labelStyle(.iconOnly)
                            }.frame( height: 24)
                            
                            TextField("Source string", text: $replaceStrLs[idx][0])
                            TextField("Replace with", text: $replaceStrLs[idx][1])
                        }
                    }
                }
            }
                
                
            HStack {
                Button {
                    replaceStrLs = [["\n",""],["\\",""]]
                    } label: {
                        Label(
                            title: { Text("Reset")  },
                            icon: { Image(systemName: "gobackward") }
                        )
                        .frame(width: 50,height: 24)
                        .labelStyle(.iconOnly)
                }.buttonStyle(.borderedProminent)
                    .tint(.green)
                
                    Button {
                        replaceStrLs.append(["",""])
                    } label: {
                        Label(
                            title: { Text("Add")  },
                            icon: { Image(systemName: "plus.diamond.fill") }
                        )
                        .frame(width: 50,height: 24)
                        .labelStyle(.iconOnly)
                }.buttonStyle(.borderedProminent)
                
                
                
            }
                
           
        }
    }
}

#Preview {
    TReplaceStrWid(replaceStrLs: .constant([["1" , "String"]]))
}
