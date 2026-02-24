import SwiftUI
#if canImport(SceneKit)
import SceneKit

public struct GlobeSceneView: UIViewRepresentable {
    public struct Configuration: Equatable {
        public var radius: CGFloat
        public var earthTextureName: String?

        public init(radius: CGFloat = 1.0, earthTextureName: String? = nil) {
            self.radius = radius
            self.earthTextureName = earthTextureName
        }
    }

    private let configuration: Configuration

    public init(configuration: Configuration = .init()) {
        self.configuration = configuration
    }

    public func makeUIView(context: Context) -> SCNView {
        let view = SCNView(frame: .zero)
        view.backgroundColor = .clear
        view.scene = buildScene(configuration: configuration)
        view.allowsCameraControl = false
        view.autoenablesDefaultLighting = false
        view.antialiasingMode = .multisampling4X
        return view
    }

    public func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = buildScene(configuration: configuration)
    }

    private func buildScene(configuration: Configuration) -> SCNScene {
        let scene = SCNScene()

        let globeNode = makeGlobeNode(configuration: configuration)
        scene.rootNode.addChildNode(globeNode)

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, Float(configuration.radius * 3.0))
        cameraNode.camera?.zNear = 0.1
        cameraNode.camera?.zFar = 100
        scene.rootNode.addChildNode(cameraNode)

        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(0, Float(configuration.radius * 2.0), Float(configuration.radius * 2.0))
        scene.rootNode.addChildNode(lightNode)

        let ambientNode = SCNNode()
        ambientNode.light = SCNLight()
        ambientNode.light?.type = .ambient
        ambientNode.light?.color = UIColor(white: 0.18, alpha: 1.0)
        scene.rootNode.addChildNode(ambientNode)

        return scene
    }

    private func makeGlobeNode(configuration: Configuration) -> SCNNode {
        let sphere = SCNSphere(radius: configuration.radius)
        sphere.segmentCount = 128

        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = configuration.earthTextureName.flatMap(UIImage.init(named:)) ?? UIColor.systemBlue
        material.roughness.contents = 0.85
        material.metalness.contents = 0.0
        sphere.firstMaterial = material

        return SCNNode(geometry: sphere)
    }
}

#else
public struct GlobeSceneView: View {
    public struct Configuration: Equatable {
        public var radius: CGFloat
        public var earthTextureName: String?

        public init(radius: CGFloat = 1.0, earthTextureName: String? = nil) {
            self.radius = radius
            self.earthTextureName = earthTextureName
        }
    }

    public init(configuration: Configuration = .init()) {}

    public var body: some View {
        Text("SceneKit unavailable on this platform")
    }
}
#endif
