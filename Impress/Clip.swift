//
//  Clip.swift
//  Impress
//
//  Created by user on 2025/05/11.
//
import SwiftUI
import TOCropViewController

struct CropViewControllerWrapper: UIViewControllerRepresentable {
    var image: UIImage
    @Binding var croppedImage: UIImage?
    @Binding var isPresented: Bool

    
    var onDismiss: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> TOCropViewController {
        let cropController = TOCropViewController(image: image)
        cropController.delegate = context.coordinator
        cropController.aspectRatioPreset = .presetSquare
        cropController.aspectRatioLockEnabled = false // true にすると比率固定
        cropController.resetAspectRatioEnabled = true
        return cropController
    }

    func updateUIViewController(_ uiViewController: TOCropViewController, context: Context) {
        // 更新処理不要
    }

    class Coordinator: NSObject, TOCropViewControllerDelegate {
        var parent: CropViewControllerWrapper

        init(_ parent: CropViewControllerWrapper) {
            self.parent = parent
        }

        func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
            parent.croppedImage = image
            parent.isPresented = false//今回isPresentedがなんのトリガーにもなってない
            parent.onDismiss()//これでcaptureImage をfalseにする ここから直接captureImageを変更できないからonDismissを使っている
            
        }

        func cropViewControllerDidCancel(_ cropViewController: TOCropViewController) {
            parent.isPresented = false//じゃあなんでこいつの場合は閉じてくれるんだよ
            parent.onDismiss()
        }
    }
}
