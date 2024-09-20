//
//  TabBarGesture.swift
//  SeaShipTracker
//
//  Created by user on 06.07.2024.
//

import SwiftUI

struct CustomGesture: UIViewRepresentable {
    @Binding var isEnabled: Bool
    
    var trigger: (Bool) -> ()
    var onChanged: (CGSize, CGPoint) -> ()
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let gesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleGesture(_:)))
        view.addGestureRecognizer(gesture)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let gesture = uiView.gestureRecognizers?.first as? UIPanGestureRecognizer {
            gesture.isEnabled = isEnabled
        }
    }
    
    class Coordinator: NSObject {
        var parent: CustomGesture

        init(_ parent: CustomGesture) {
            self.parent = parent
        }

        @objc func handleGesture(_ recognizer: UIPanGestureRecognizer) {
            let view = recognizer.view
            let globalLocation = recognizer.location(in: nil) // nil means the window's coordinate system
            let translation = recognizer.translation(in: view)
            
            let offset = CGSize(width: translation.x, height: translation.y)
            
            switch recognizer.state {
            case .began:
                parent.trigger(true)
            case .ended, .cancelled, .failed:
                parent.trigger(false)
            default:
                parent.onChanged(offset, globalLocation)
            }
        }
    }
}
