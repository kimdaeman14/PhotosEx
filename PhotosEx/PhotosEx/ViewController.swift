//
//  ViewController.swift
//  PhotosEx
//
//  Created by kimdaeman14 on 2018. 8. 3..
//  Copyright © 2018년 GoldenShoe. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UITableViewDataSource,UITableViewDelegate,  PHPhotoLibraryChangeObserver {
    
    
    //포토라이브러리바뀌면실행될옵저버
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: fetchResult) else {return}
        
        //어떤게바꼇는지 바뀐결과가 fetchResult로들어가고
        fetchResult = changes.fetchResultAfterChanges
        
        //바꼇으면테이블뷰를다시불러달라 다시 리로드. 
        OperationQueue.main.addOperation {
            self.tableView.reloadSections(IndexSet(0...0), with: .automatic)
        }

    }
    
    
    @IBOutlet weak var tableView:UITableView!
    var fetchResult: PHFetchResult<PHAsset>!
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    let cellIdentifier:String = "cell"
    
    //어떤 로우를 우리가 편집할수있게할거냐? 메서드
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //삭제모드로들어왔을때, 삭제냐? 그러면 아래코드를실행
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            //아래 에셋을 가지고
            let asset: PHAsset = self.fetchResult[indexPath.row]
            
            //딜리트버튼 누르면 창이 뜨는 부분
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets([asset] as NSArray)
            }, completionHandler: nil)
        }
    }
    
    
    
    
    func requestCollection(){
        
        let cameraRoll: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.smartAlbumUserLibrary, options: nil) //iphone 카메라롤 그거를 선언했고.
        
        guard let cameraRollCollection = cameraRoll.firstObject else {return} //안비어있으면 내려가

        let fetchOption = PHFetchOptions() //최신순으로 정렬하고
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        //그결과를 fetchResult에 저장
        self.fetchResult = PHAsset.fetchAssets(in: cameraRollCollection, options: fetchOption)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
        case .authorized:
            print("접근허가됨")
            self.requestCollection()
            self.tableView.reloadData()

        case .denied:
            print("접근불허")
        case .notDetermined:
            print("아직응답하지않음")
            PHPhotoLibrary.requestAuthorization { (status) in
                switch status{
                case .authorized:
                    print("사용자가 허용함")
                    self.requestCollection()
                    OperationQueue.main.addOperation {
                        self.tableView.reloadData()
                    }
                case .denied:
                    print("사용자가 불허함")
                default: break
                }
            }
        case .restricted:
            print("접근제한")
        
    }
        
        PHPhotoLibrary.shared().register(self)
    
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchResult?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
        
        let asset: PHAsset = fetchResult.object(at: indexPath.row) //에셋은 이미지에서 index역할하는거고
        
        //imageManager를 통해서 이미지를 요청해. 테이블뷰에 하나씩 이미지를 꽂아줄거야.
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 30, height: 30), contentMode: .aspectFill, options: nil) { image, _ in
            cell.imageView?.image = image
        }
        return cell
    }
    
    
    
}

