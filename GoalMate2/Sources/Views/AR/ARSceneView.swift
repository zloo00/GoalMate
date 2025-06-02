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

    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView()
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene = SCNScene()

        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)

        addGoalSpheres(to: sceneView)

        return sceneView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Очистим сцену перед повторной отрисовкой
        uiView.scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
        addGoalSpheres(to: uiView)
    }

    private func addGoalSpheres(to sceneView: ARSCNView) {
        // Сортируем по dueDate
        let sortedGoals = goals.sorted { $0.dueDate < $1.dueDate }

        for (index, goal) in sortedGoals.enumerated() {
            let sphere = SCNSphere(radius: 0.05)

            switch goal.priority {
            case .low:
                sphere.firstMaterial?.diffuse.contents = UIColor.systemGreen
            case .medium:
                sphere.firstMaterial?.diffuse.contents = UIColor.systemYellow
            case .high:
                sphere.firstMaterial?.diffuse.contents = UIColor.systemRed
            }

            let node = SCNNode(geometry: sphere)
            node.position = SCNVector3(Float(index) * 0.2, 0, -0.5 - Float(index) * 0.1)

            // Добавим текст
            let text = SCNText(string: goal.title, extrusionDepth: 0.5)
            text.font = UIFont.systemFont(ofSize: 2)
            text.firstMaterial?.diffuse.contents = UIColor.white

            let textNode = SCNNode(geometry: text)
            textNode.scale = SCNVector3(0.005, 0.005, 0.005)
            textNode.position = SCNVector3(node.position.x - 0.05, node.position.y + 0.07, node.position.z)

            sceneView.scene.rootNode.addChildNode(node)
            sceneView.scene.rootNode.addChildNode(textNode)
        }
    }
}
