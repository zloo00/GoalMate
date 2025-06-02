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
        context.coordinator.addGoalSpheres(to: sceneView)

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
            if let sceneView = sceneView {
                addGoalSpheres(to: sceneView)
            }
        }

        func addGoalSpheres(to sceneView: ARSCNView) {
            let sortedGoals = goals.sorted { $0.dueDate < $1.dueDate }

            for (index, goal) in sortedGoals.enumerated() {
                let sphere = SCNSphere(radius: 0.05)
                let color: UIColor

                switch goal.priority {
                case .high: color = .systemRed
                case .medium: color = .systemOrange
                case .low: color = .systemGreen
                }

                sphere.firstMaterial?.diffuse.contents = color

                let node = SCNNode(geometry: sphere)
                node.name = "goal_\(goal.id)"
                node.position = SCNVector3(Float(index) * 0.2, 0, -0.5 - Float(index) * 0.1)

                node.scale = SCNVector3(0.01, 0.01, 0.01)
                let scaleUp = SCNAction.scale(to: 1.0, duration: 0.5)
                scaleUp.timingMode = .easeOut

                let moveUp = SCNAction.moveBy(x: 0, y: 0.05, z: 0, duration: 1.5)
                let moveDown = SCNAction.moveBy(x: 0, y: -0.05, z: 0, duration: 1.5)
                let floatSequence = SCNAction.sequence([moveUp, moveDown])
                let floating = SCNAction.repeatForever(floatSequence)

                node.runAction(SCNAction.sequence([scaleUp, floating]))

                let maxLength = 20
                let title = goal.title.count > maxLength ? String(goal.title.prefix(maxLength)) + "…" : goal.title

                let textGeometry = SCNText(string: title, extrusionDepth: 0.5)
                textGeometry.firstMaterial?.diffuse.contents = UIColor.white
                textGeometry.font = UIFont.systemFont(ofSize: 4)
                textGeometry.flatness = 0.1

                let textNode = SCNNode(geometry: textGeometry)
                textNode.scale = SCNVector3(0.003, 0.003, 0.003)

                let (min, max) = textGeometry.boundingBox
                let textWidth = max.x - min.x
                textNode.position = SCNVector3(-textWidth * 0.0015, -0.07, 0)

                textNode.constraints = [SCNBillboardConstraint()]

                node.addChildNode(textNode)
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
