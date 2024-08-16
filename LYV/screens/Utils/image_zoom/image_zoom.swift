import UIKit

class ImageZoomHelper {

    static func presentZoomedImage(from imageView: UIImageView, in viewController: UIViewController) {
        guard let image = imageView.image else { return }
        
        // Create the overlay view
        let overlayView = UIView(frame: viewController.view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        overlayView.alpha = 0
        viewController.view.addSubview(overlayView)
        
        // Create the zoomed-in image view
        let zoomedImageView = UIImageView(image: image)
        zoomedImageView.contentMode = .scaleAspectFit
        zoomedImageView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        zoomedImageView.center = overlayView.center
        overlayView.addSubview(zoomedImageView)
        
        // Animate the zoom effect
        UIView.animate(withDuration: 0.3, animations: {
            overlayView.alpha = 1
            let zoomedFrame = CGRect(
                x: 0,
                y: 0,
                width: viewController.view.bounds.width,
                height: viewController.view.bounds.height
            )
            zoomedImageView.frame = zoomedFrame
        })
        
        // Add tap gesture to dismiss the overlay
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissZoomedImage(_:)))
        overlayView.addGestureRecognizer(tapGesture)
    }
    
    @objc private static func dismissZoomedImage(_ sender: UITapGestureRecognizer) {
        guard let overlayView = sender.view else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            overlayView.alpha = 0
        }) { _ in
            overlayView.removeFromSuperview()
        }
    }
}
