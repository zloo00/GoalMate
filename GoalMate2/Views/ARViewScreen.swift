//
//  ARViewScreen.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 29.05.2025.
//
import SwiftUI
import RealityKit
import ARKit

struct ARViewScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var arError: String?
    @State private var showPlacementInstructions = true
    
    var body: some View {
        ZStack {
            ARTreeViewContainer(arError: $arError)
                .edgesIgnoringSafeArea(.all)
            
            if showPlacementInstructions {
                VStack {
                    Spacer()
                    Text("Tap anywhere to place your tree")
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showPlacementInstructions = false
                        }
                    }
                }
            }
            
            if let error = arError {
                VStack {
                    Text("AR Error")
                        .font(.headline)
                    Text(error)
                        .font(.subheadline)
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

struct ARTreeViewContainer: UIViewRepresentable {
    @Binding var arError: String?
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        // Set up session delegate
        context.coordinator.arView = arView
        arView.session.delegate = context.coordinator
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        // Run configuration
        arView.session.run(config)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARTreeViewContainer
        weak var arView: ARView?
        var treeAnchor: AnchorEntity?
        
        init(_ parent: ARTreeViewContainer) {
            self.parent = parent
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            
            let tapLocation = sender.location(in: arView)
            
            // Perform ray casting to find where to place the tree
            if let result = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .any).first {
                // Remove previous tree if exists
                if let existingAnchor = treeAnchor {
                    arView.scene.removeAnchor(existingAnchor)
                }
                
                // Create new anchor at tap location
                let anchor = AnchorEntity(world: result.worldTransform)
                self.treeAnchor = anchor
                
                // Create realistic tree
                let tree = createRealisticTree()
                anchor.addChild(tree)
                
                // Add to scene
                arView.scene.addAnchor(anchor)
                
                // Add slight animation
                tree.scale = SIMD3(0.1, 0.1, 0.1)
                tree.move(to: Transform(scale: .one), relativeTo: tree.parent, duration: 0.5, timingFunction: .easeInOut)
            }
        }
        
        private func createRealisticTree() -> Entity {
            let tree = Entity()
            
            // Trunk with better geometry
            let trunk = ModelEntity(
                mesh: .generateCylinder(height: 0.5, radius: 0.05),
                materials: [SimpleMaterial(
                    color: UIColor(
                        red: 0.4,
                        green: 0.2,
                        blue: 0.0,
                        alpha: 1.0
                    ),
                    roughness: 0.8,
                    isMetallic: false
                )]
            )
            trunk.position.y = 0.25
            
            // Leaves/Crown with multiple spheres for better look
            let crownBase = Entity()
            
            // Main crown
            let mainCrown = ModelEntity(
                mesh: .generateSphere(radius: 0.2),
                materials: [SimpleMaterial(
                    color: UIColor(
                        red: 0.0,
                        green: 0.5,
                        blue: 0.0,
                        alpha: 1.0
                    ),
                    roughness: 0.7,
                    isMetallic: false
                )]
            )
            mainCrown.position.y = 0.5
            
            // Smaller crowns for more natural look
            let smallCrown1 = ModelEntity(
                mesh: .generateSphere(radius: 0.15),
                materials: [SimpleMaterial(
                    color: UIColor(
                        red: 0.1,
                        green: 0.6,
                        blue: 0.1,
                        alpha: 1.0
                    ),
                    roughness: 0.7,
                    isMetallic: false
                )]
            )
            smallCrown1.position = SIMD3(0.1, 0.55, 0.1)
            
            let smallCrown2 = ModelEntity(
                mesh: .generateSphere(radius: 0.12),
                materials: [SimpleMaterial(
                    color: UIColor(
                        red: 0.2,
                        green: 0.5,
                        blue: 0.1,
                        alpha: 1.0
                    ),
                    roughness: 0.7,
                    isMetallic: false
                )]
            )
            smallCrown2.position = SIMD3(-0.15, 0.6, -0.1)
            
            // Assemble the tree
            crownBase.addChild(mainCrown)
            crownBase.addChild(smallCrown1)
            crownBase.addChild(smallCrown2)
            
            tree.addChild(trunk)
            tree.addChild(crownBase)
            
            return tree
        }
        
        // ARSessionDelegate methods
        func session(_ session: ARSession, didFailWithError error: Error) {
            DispatchQueue.main.async {
                self.parent.arError = "AR Session Failed: \(error.localizedDescription)"
            }
        }
        
        func sessionWasInterrupted(_ session: ARSession) {
            DispatchQueue.main.async {
                self.parent.arError = "AR Session Interrupted"
            }
        }
        
        func sessionInterruptionEnded(_ session: ARSession) {
            DispatchQueue.main.async {
                self.parent.arError = nil
                self.restartSession()
            }
        }
        
        func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
            DispatchQueue.main.async {
                switch camera.trackingState {
                case .normal:
                    self.parent.arError = nil
                case .notAvailable:
                    self.parent.arError = "Tracking not available"
                case .limited(let reason):
                    self.parent.arError = self.trackingStateReasonDescription(reason)
                }
            }
        }
        
        private func trackingStateReasonDescription(_ reason: ARCamera.TrackingState.Reason) -> String {
            switch reason {
            case .initializing:
                return "Initializing - move your device slowly"
            case .excessiveMotion:
                return "Too much movement - slow down"
            case .insufficientFeatures:
                return "Not enough detail - point at a textured surface"
            case .relocalizing:
                return "Relocalizing - keep your device steady"
            @unknown default:
                return "Tracking limited - unknown reason"
            }
        }
        
        private func restartSession() {
            guard let arView = self.arView else { return }
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal, .vertical]
            config.environmentTexturing = .automatic
            arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        }
    }
}
