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

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ARTreeViewContainer()
                .edgesIgnoringSafeArea(.all)

            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}

struct ARTreeViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        arView.session.run(config)

        // Пример: дерево из цилиндра и сфер (ствол + листва)
        let treeAnchor = AnchorEntity(plane: .horizontal)

        // Ствол дерева
        let trunk = ModelEntity(
            mesh: .generateCylinder(height: 0.2, radius: 0.02),
            materials: [SimpleMaterial(color: .brown, isMetallic: false)]
        )
        trunk.position = SIMD3(0, 0.1, 0)

        // Крона дерева
        let crown = ModelEntity(
            mesh: .generateSphere(radius: 0.06),
            materials: [SimpleMaterial(color: .green, isMetallic: false)]
        )
        crown.position = SIMD3(0, 0.23, 0)

        treeAnchor.addChild(trunk)
        treeAnchor.addChild(crown)

        arView.scene.anchors.append(treeAnchor)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}