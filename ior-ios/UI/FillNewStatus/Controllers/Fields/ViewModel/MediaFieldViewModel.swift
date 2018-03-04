//
//  MediaFieldViewModel.swift
//  ior-ios
//
//  Created by me on 22/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import Alamofire

protocol MediaFieldViewModelDelegate: class {
    func urlsDidUpdated()
}

class MediaFieldViewModel {
    
    weak var delegate: MediaFieldViewModelDelegate?
    
    var photo_urls: [String] = []
    var video_urls: [String] = []
    
    var uploads: [Upload] = [] {
        didSet {
            delegate?.urlsDidUpdated()
        }
    }
    
    func upload(mode: MediaFieldMode, videoURL: URL? = nil, image: UIImage? = nil, onProgress: @escaping (Double) -> (),  completion: @escaping (Bool) -> ()) {
        guard let url = URL(string: APIMode.Backend + "/upload") else { return }
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if mode == .Image {
                guard let image = image else { return }
                multipartFormData.append(UIImageJPEGRepresentation(image.rotateCameraImageToProperOrientation(maxResolution: 1024) ?? UIImage(), 1) ?? Data(), withName: "file", fileName: "file.jpeg", mimeType: "image/jpeg")
            } else {
                guard let videoURL = videoURL else { return }
                multipartFormData.append(videoURL, withName: "file", fileName: "file.mov", mimeType: "video/mp4")
            }
        }, to: url) { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print(progress)
                    onProgress(progress.fractionCompleted)
                })
                
                upload.responseJSON { [weak self] response in
                    guard let strongSelf = self else { return }
                    guard let result = response.result.value as? [[String: Any]] else { return }
                    let upload = Upload(dict: result[0])
                    strongSelf.uploads.append(upload)
                    if mode == .Image {
                        strongSelf.photo_urls.append(upload.url)
                    } else {
                        strongSelf.video_urls.append(upload.url)
                    }
                    completion(true)
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func delete(index: Int) {
//        APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/upload/delete", parameters: ["_id": "\(uploads[index]._id)", "url": "\(uploads[index].url)"], completion:  { (response, error) in
//
//            if error == nil {
                self.uploads.remove(at: index)
//            }
//        })
    }
}
