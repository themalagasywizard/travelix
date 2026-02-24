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

    public func makeCoordinator() -> Coordinator {
        Coordinator(configuration: configuration)
    }

    public func makeUIView(context: Context) -> SCNView {
        let view = SCNView(frame: .zero)
        view.backgroundColor = .clear
        view.allowsCameraControl = false
        view.autoenablesDefaultLighting = false
        view.antialiasingMode = .multisampling4X

        let sceneNodes = buildScene(configuration: configuration)
        view.scene = sceneNodes.scene
        context.coordinator.attach(to: view, globeNode: sceneNodes.globeNode, cameraNode: sceneNodes.cameraNode)

        return view
    }

    public func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.update(configuration: configuration)
        if let sphere = context.coordinator.globeNode?.geometry as? SCNSphere {
            sphere.radius = configuration.radius
            sphere.firstMaterial?.diffuse.contents = configuration.earthTextureName.flatMap(UIImage.init(named:)) ?? UIColor.systemBlue
        }
        context.coordinator.updateCameraDistanceIfNeeded()
    }

    private func buildScene(configuration: Configuration) -> (scene: SCNScene, globeNode: SCNNode, cameraNode: SCNNode) {
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

        return (scene, globeNode, cameraNode)
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

public extension GlobeSceneView {
    final class Coordinator: NSObject {
        private var configuration: Configuration

        weak var globeNode: SCNNode?
        weak var cameraNode: SCNNode?

        private var inertiaVelocity = CGPoint.zero
        private var displayLink: CADisplayLink?
        private var lastFrameTimestamp: CFTimeInterval?
        private var currentCameraDistance: CGFloat

        init(configuration: Configuration) {
            self.configuration = configuration
            self.currentCameraDistance = configuration.radius * 3.0
        }

        deinit {
            stopInertia()
        }

        func update(configuration: Configuration) {
            self.configuration = configuration
            let minDistance = configuration.radius * 1.4
            let maxDistance = configuration.radius * 6.0
            currentCameraDistance = max(minDistance, min(maxDistance, currentCameraDistance))
        }

        func attach(to view: SCNView, globeNode: SCNNode, cameraNode: SCNNode) {
            self.globeNode = globeNode
            self.cameraNode = cameraNode
            self.currentCameraDistance = configuration.radius * 3.0

            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            pan.maximumNumberOfTouches = 1
            view.addGestureRecognizer(pan)

            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            view.addGestureRecognizer(pinch)
        }

        func updateCameraDistanceIfNeeded() {
            cameraNode?.position.z = Float(currentCameraDistance)
        }

        @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
            guard let view = recognizer.view else { return }

            let translation = recognizer.translation(in: view)
            let sensitivity: CGFloat = 0.005

            switch recognizer.state {
            case .began:
                stopInertia()

            case .changed:
                applyRotation(deltaX: translation.x * sensitivity, deltaY: translation.y * sensitivity)
                recognizer.setTranslation(.zero, in: view)

            case .ended:
                let velocity = recognizer.velocity(in: view)
                inertiaVelocity = CGPoint(x: velocity.x * 0.002, y: velocity.y * 0.002)
                startInertia()

            case .cancelled, .failed:
                stopInertia()

            default:
                break
            }
        }

        @objc private func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
            stopInertia()

            switch recognizer.state {
            case .changed:
                let minDistance = configuration.radius * 1.4
                let maxDistance = configuration.radius * 6.0
                let proposed = currentCameraDistance / recognizer.scale
                currentCameraDistance = max(minDistance, min(maxDistance, proposed))
                cameraNode?.position.z = Float(currentCameraDistance)
                recognizer.scale = 1.0

            default:
                break
            }
        }

        private func applyRotation(deltaX: CGFloat, deltaY: CGFloat) {
            guard let globeNode else { return }

            let nextX = CGFloat(globeNode.eulerAngles.x) + deltaY
            let clampedX = max(-(.pi / 2), min(.pi / 2, nextX))

            globeNode.eulerAngles.x = Float(clampedX)
            globeNode.eulerAngles.y += Float(deltaX)
        }

        private func startInertia() {
            guard displayLink == nil else { return }

            let link = CADisplayLink(target: self, selector: #selector(stepInertia(_:)))
            link.add(to: .main, forMode: .common)
            displayLink = link
        }

        private func stopInertia() {
            displayLink?.invalidate()
            displayLink = nil
            lastFrameTimestamp = nil
            inertiaVelocity = .zero
        }

        @objc private func stepInertia(_ link: CADisplayLink) {
            let dt: CGFloat
            if let last = lastFrameTimestamp {
                dt = CGFloat(link.timestamp - last)
            } else {
                dt = 1.0 / 60.0
            }
            lastFrameTimestamp = link.timestamp

            applyRotation(deltaX: inertiaVelocity.x * dt, deltaY: inertiaVelocity.y * dt)

            let dampingPer60fpsFrame: CGFloat = 0.92
            let damping = pow(dampingPer60fpsFrame, dt * 60.0)
            inertiaVelocity.x *= damping
            inertiaVelocity.y *= damping

            if abs(inertiaVelocity.x) < 0.01, abs(inertiaVelocity.y) < 0.01 {
                stopInertia()
            }
        }
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
