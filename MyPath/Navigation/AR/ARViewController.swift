//
//  ARViewController.swift
//  MyPath
//
//  Created by Illia Kniaziev on 14.05.2022.
//

import ARKit
import CoreLocation
import MapboxSceneKit
import SceneKit
import UIKit

class ARViewController: ViewController, UIGestureRecognizerDelegate, ARSessionDelegate & ARSCNViewDelegate {
    @IBOutlet private weak var arView: ARSCNView?
    @IBOutlet private weak var placeButton: UIButton?
    @IBOutlet private weak var moveImage: UIImageView?
    @IBOutlet private weak var messageView: UIVisualEffectView?
    @IBOutlet private weak var messageLabel: UILabel?
    
    var isSimultaneousRotationAndZoomingDisallowed = false
    
    private weak var terrain: SCNNode?
    private var pathPoints: [Weak<SCNNode>] = []
    private var planes: [UUID: SCNNode] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        arView!.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        arView!.session.delegate = self
        arView!.delegate = self
        if let camera = arView?.pointOfView?.camera {
            camera.wantsHDR = true
            camera.wantsExposureAdaptation = true
        }

        arView!.isUserInteractionEnabled = false
        setupGestures()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        restartTracking()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIApplication.shared.isIdleTimerDisabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        arView?.session.pause()
        UIApplication.shared.isIdleTimerDisabled = false
    }

    // MARK: - SCNSceneRendererDelegate

    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocusSquare()
        }
    }

    // MARK: - IBActions

    @IBAction func place(_ sender: AnyObject?) {
        let tapPoint = screenCenter
        var result = arView?.smartRaycast(tapPoint)
        if result == nil {
            result = arView?.smartRaycast(tapPoint, infinitePlane: true)
        }

        guard result != nil, let anchor = result?.anchor, let plane = planes[anchor.identifier] else {
            return
        }

        insert(on: plane, from: result!)
        arView?.debugOptions = []

        self.placeButton?.isHidden = true
    }

    private func insert(on plane: SCNNode, from raycastResult: ARRaycastResult) {
        //Set up initial terrain and materials
        let terrainNode = TerrainNode(minLat: 48.599523, maxLat: 48.626899,
                                      minLon: 23.915913, maxLon: 23.955292)

        let camera = arView?.session.currentFrame?.camera
        let cameraPositon = camera?.transform.columns.3
        let raycastAnchorPosition = raycastResult.anchor?.transform.columns.3
        
        guard let cameraPositon = cameraPositon, let raycastAnchorPosition = raycastAnchorPosition else {
            print("FAILED TO INSERT c:\(String(describing: cameraPositon)) r:\(String(describing: raycastAnchorPosition))")
            return
        }
        
        let distance = length(cameraPositon - raycastAnchorPosition)
        print(distance)
        
        let scale = Float(0.333 * distance) / terrainNode.boundingSphere.radius
        terrainNode.transform = SCNMatrix4MakeScale(scale, scale, scale)
        terrainNode.position = SCNVector3(raycastResult.worldTransform.columns.3.x,
                                          raycastResult.worldTransform.columns.3.y,
                                          raycastResult.worldTransform.columns.3.z)
        terrainNode.geometry?.materials = defaultMaterials()
        arView!.scene.rootNode.addChildNode(terrainNode)
        terrain = terrainNode
        terrainNode.fetchTerrainAndTexture(
            minWallHeight: 50.0,
            enableDynamicShadows: true,
            textureStyle: MapboxMapStyler.MapStyle.sattelite.rawValue,
            heightCompletion: { fetchError in
                if let fetchError = fetchError {
                    print("Terrain load failed: \(fetchError.localizedDescription)")
                } else {
                    print("Terrain load complete")
                }
            },
            textureCompletion: { image, fetchError in
                if let fetchError = fetchError {
                    print("Texture load failed: \(fetchError.localizedDescription)")
                }
                if image != nil {
                    print("Texture load complete")
                    terrainNode.geometry?.materials[4].diffuse.contents = image
                }
            }
        )

        arView!.isUserInteractionEnabled = true
    }

    private func defaultMaterials() -> [SCNMaterial] {
        let groundImage = SCNMaterial()
        groundImage.diffuse.contents = UIColor.white
        groundImage.name = "Ground texture"

        let sideMaterial = SCNMaterial()
        sideMaterial.diffuse.contents = UIColor.systemGray
        sideMaterial.isDoubleSided = true
        sideMaterial.name = "Side"

        let bottomMaterial = SCNMaterial()
        bottomMaterial.diffuse.contents = UIColor.systemGray
        bottomMaterial.name = "Bottom"

        return [sideMaterial, sideMaterial, sideMaterial, sideMaterial, groundImage, bottomMaterial]
    }

    // MARK: - ARSCNViewDelegate

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.simdPosition = SIMD3<Float>(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.eulerAngles.x = -.pi / 2
        planeNode.isHidden = true
        node.addChildNode(planeNode)

        planes[anchor.identifier] = planeNode

        DispatchQueue.main.async {
            self.setMessage("")
            if self.terrain == nil {
                self.placeButton?.isHidden = false
                self.moveImage?.isHidden = true
            }
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }

        planeNode.simdPosition = SIMD3<Float>(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)

        planes[anchor.identifier] = planeNode
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        node.removeFromParentNode()
        planes.removeValue(forKey: anchor.identifier)

        if planes.isEmpty {
            DispatchQueue.main.async {
                self.terrain?.removeFromParentNode()
                self.moveImage?.isHidden = false
                self.arView?.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
            }
        }
    }

    // MARK: - ARSessionDelegate

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }

    // MARK: - ARSessionObserver

    func sessionWasInterrupted(_ session: ARSession) {
        setMessage("Session was interrupted")
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        setMessage("Session interruption ended")

        restartTracking()
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        setMessage("Session failed: \(error.localizedDescription)")

        restartTracking()
    }

    // MARK: - Focus Square

    var focusSquare: FocusSquare?

    func setupFocusSquare() {
        focusSquare?.isHidden = true
        focusSquare?.removeFromParentNode()
        focusSquare = FocusSquare()
        arView?.scene.rootNode.addChildNode(focusSquare!)
    }

    func updateFocusSquare() {
        guard let arView = arView else { return }

        if !arView.isUserInteractionEnabled, let result = arView.smartRaycast(screenCenter, infinitePlane: true), let planeAnchor = result.anchor as? ARPlaneAnchor {
            let position: SCNVector3 = SCNVector3(result.worldTransform.columns.3)
            focusSquare?.update(for: position, planeAnchor: planeAnchor, camera: arView.session.currentFrame?.camera)
            focusSquare?.unhide()
        } else {
            focusSquare?.hide()
        }
    }

    // MARK: - Message Helpers

    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        let message: String

        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            message = "Move the device around to detect flat surfaces."

        case .notAvailable:
            message = "Tracking unavailable."

        case .limited(.excessiveMotion):
            message = "Move the device more slowly."

        case .limited(.insufficientFeatures):
            message = "Point the device at an area with visible surface detail, or improve lighting conditions."

        case .limited(.initializing):
            message = "Initializing AR session."

        default:
            message = ""
        }

        setMessage(message)
    }

    private func setMessage(_ message: String) {
        self.messageLabel?.text = message
        self.messageView?.isHidden = message.isEmpty
    }

    // MARK: - UIGestureRecognizer

    private func setupGestures() {
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        rotate.delegate = self
        arView?.addGestureRecognizer(rotate)
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinch.delegate = self
        arView?.addGestureRecognizer(pinch)
        
        let drag = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        drag.delegate = self
        drag.minimumNumberOfTouches = 1
        drag.maximumNumberOfTouches = 1
        arView?.addGestureRecognizer(drag)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView?.addGestureRecognizer(tap)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if isSimultaneousRotationAndZoomingDisallowed {
            let simultaniousPinchDragFlag1 = gestureRecognizer is UIRotationGestureRecognizer ||
                                             gestureRecognizer is UIPinchGestureRecognizer
            let simultaniousPinchDragFlag2 = otherGestureRecognizer is UIRotationGestureRecognizer ||
                                             otherGestureRecognizer is UIPinchGestureRecognizer
            
            if simultaniousPinchDragFlag1 && simultaniousPinchDragFlag2 {
                return false
            }
        }
        
        return gestureRecognizer.numberOfTouches == otherGestureRecognizer.numberOfTouches
    }
    
    @objc fileprivate func handleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: gesture.view!)
        if let raycastResultPosition = arView?.smartRaycast(point, infinitePlane: true)?.worldTransform.columns.3,
           let cameraPosition = session.currentFrame?.camera.transform.columns.3 {
            let origin = SCNVector3(cameraPosition)
            let destination = SCNVector3(raycastResultPosition)
            
            #if DEBUG
            let sphereNode = SCNGeometry.shpere(at: destination)
            pathPoints.append(Weak(sphereNode))
            arView?.scene.rootNode.addChildNode(sphereNode)
            #endif
            
            let scnHitTestResult = arView?.scene.rootNode.hitTestWithSegment(from: origin, to: destination)
            if let scnPosition = scnHitTestResult?.first(where: { $0.node is TerrainNode })?.worldCoordinates {
                print("🎯 \(scnPosition)")
                let scnSphere = SCNGeometry.shpere(at: scnPosition, withRadius: 0.001, withColour: .systemPink)
                pathPoints.append(Weak(scnSphere))
                arView?.scene.rootNode.addChildNode(scnSphere)
            }
        }
    }

    private var lastDragResult: ARRaycastResult?
    @objc fileprivate func handleDrag(_ gesture: UIRotationGestureRecognizer) {
        guard let terrain = terrain else {
            return
        }

        let point = gesture.location(in: gesture.view!)
        if let result = arView?.smartRaycast(point, infinitePlane: true) {
            if let lastDragResult = lastDragResult {
                let diff = result.worldTransform.columns.3 - lastDragResult.worldTransform.columns.3
                let vector: SCNVector3 = SCNVector3(diff)
                terrain.position += vector
                pathPoints.forEach { $0.value?.position += vector }
            }
            lastDragResult = result
        }

        if gesture.state == .ended {
            self.lastDragResult = nil
        }
    }
    
    private var startScale: Float?
    private var initialPathScale: SCNVector3?
    private var initialTerrainPosition: SCNVector3?
    private var initialPathPointsPositions: [SCNVector3] = []
    private var isUserZooming = false

    @objc fileprivate func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard let terrain = terrain else {
            return
        }
        
        let gestureRotation = Float(gesture.rotation)
        
        let pivotTerrainCenter = terrain.position

        terrain.eulerAngles.y = GeometryManager.getNormalizedRotation(eulerAngleY: terrain.eulerAngles.y, rotation: gestureRotation)
        
        zip(pathPoints, 0..<pathPoints.count).forEach { weakNode, initialPositionIndex in
            guard let node = weakNode.value else { return }

            node.position = GeometryManager.rotateOnHorizontalPlain(point: node.position,
                                                                    around: pivotTerrainCenter,
                                                                    by: gestureRotation)
            
            if isUserZooming {
                let initialNodePosition = initialPathPointsPositions[initialPositionIndex]
                initialPathPointsPositions[initialPositionIndex] = GeometryManager.rotateOnHorizontalPlain(point: initialNodePosition,
                                                                                                           around: pivotTerrainCenter,
                                                                                                           by: gestureRotation)
            }
        }
        
        gesture.rotation = 0
    }

    @objc fileprivate func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let terrain = terrain else { return }
        
        if gesture.state == .began {
            startScale = terrain.scale.x
            initialTerrainPosition = terrain.position
            
            pathPoints = pathPoints.compactMap { $0 }
            initialPathScale = pathPoints.first?.value?.scale
            initialPathPointsPositions = pathPoints.compactMap { $0.value?.position }
            
            isUserZooming = true
        }
        
        guard let startScale = startScale else { return }
        let gestureScale = Float(gesture.scale)
        
        let newScale: Float = startScale * gestureScale
        let newScaleVec = SCNVector3(newScale, newScale, newScale)
        terrain.scale = newScaleVec
        
        if let initialPathScale = initialPathScale, let initialTerrainPosition = initialTerrainPosition {
            let newPathScale = initialPathScale * gestureScale
            zip(pathPoints, initialPathPointsPositions).forEach { weakNode, position in
                guard let node = weakNode.value else { return }

                node.scale = newPathScale

                let ratio = gestureScale / (1 - gestureScale)
                node.position = GeometryManager.getPointDevidingLineSegment(withRatio: ratio, from: initialTerrainPosition, to: position)
            }
        }
        
        if gesture.state == .ended {
            self.startScale = nil
            self.isUserZooming = false
        }
    }

    //MARK: - Misc Helpers

    private func restartTracking() {
        terrain?.removeFromParentNode()
        for (_, plane) in planes {
            plane.removeFromParentNode()
        }
        planes.removeAll()

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true

        arView?.session.run(configuration, options: [.removeExistingAnchors])
        arView?.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        arView?.isUserInteractionEnabled = false
        placeButton?.isHidden = true
        moveImage?.isHidden = false

        setupFocusSquare()

        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }

    private var screenCenter: CGPoint {
        let bounds = arView!.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }

    private var session: ARSession {
        return arView!.session
    }
}
