//
//  ARSceneView.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 02.06.2025.
//
import SwiftUI
import ARKit
import SceneKit

struct ARSceneView: UIViewRepresentable {
    var goals: [GoalListItem]
    var onGoalSelected: (GoalListItem) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView()
        sceneView.delegate = context.coordinator
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene = SCNScene()

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        sceneView.session.run(config)

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)

        context.coordinator.sceneView = sceneView
        context.coordinator.addGoalSpheres()

        return sceneView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        context.coordinator.goals = goals
        context.coordinator.refreshGoals()
    }

    class Coordinator: NSObject, ARSCNViewDelegate {
        var parent: ARSceneView
        var sceneView: ARSCNView?
        var goals: [GoalListItem]

        init(_ parent: ARSceneView) {
            self.parent = parent
            self.goals = parent.goals
        }

        func refreshGoals() {
            sceneView?.scene.rootNode.childNodes.filter { $0.name?.starts(with: "goal_") == true }.forEach {
                $0.removeFromParentNode()
            }
            addGoalSpheres()
        }

        func addGoalSpheres() {
            guard let sceneView else { return }

            for (index, goal) in goals.enumerated() {
                let sphere = SCNSphere(radius: 0.05)
                let material = SCNMaterial()
                material.diffuse.contents = {
                    switch goal.priority {
                    case .high: return UIColor.red
                    case .medium: return UIColor.orange
                    case .low: return UIColor.green
                    }
                }()
                sphere.materials = [material]

                let node = SCNNode(geometry: sphere)
                node.name = "goal_\(goal.id)"
                node.position = SCNVector3(Float(index) * 0.2, 0, -0.5 - Float(index) * 0.1)

                node.scale = SCNVector3(0.01, 0.01, 0.01)
                let scaleUp = SCNAction.scale(to: 1.0, duration: 0.5)
                scaleUp.timingMode = .easeOut

                let moveUp = SCNAction.moveBy(x: 0, y: 0.05, z: 0, duration: 1.5)
                let moveDown = SCNAction.moveBy(x: 0, y: -0.05, z: 0, duration: 1.5)
                let float = SCNAction.repeatForever(SCNAction.sequence([moveUp, moveDown]))

                node.runAction(SCNAction.sequence([scaleUp, float]))
                sceneView.scene.rootNode.addChildNode(node)
            }
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let sceneView = gesture.view as? ARSCNView else { return }
            let location = gesture.location(in: sceneView)
            let hitResults = sceneView.hitTest(location, options: nil)

            if let node = hitResults.first?.node,
               let name = node.name,
               name.starts(with: "goal_") {
                let goalId = name.replacingOccurrences(of: "goal_", with: "")
                if let goal = goals.first(where: { $0.id == goalId }) {
                    let scaleDown = SCNAction.scale(to: 0.8, duration: 0.1)
                    let scaleUp = SCNAction.scale(to: 1.0, duration: 0.3)
                    scaleUp.timingMode = .easeOut
                    node.runAction(SCNAction.sequence([scaleDown, scaleUp]))

                    parent.onGoalSelected(goal)
                }
            }
        }
    }
}
