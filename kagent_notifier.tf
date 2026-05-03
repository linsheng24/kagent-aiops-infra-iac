resource "kubernetes_manifest" "flash_model_config" {
  manifest = {
    apiVersion = "kagent.dev/v1alpha2"
    kind       = "ModelConfig"
    metadata = {
      name      = "flash-model-config"
      namespace = "kagent"
    }
    spec = {
      provider        = "Gemini"
      model           = "gemini-2.5-flash"
      apiKeySecret    = "kagent-gemini"
      apiKeySecretKey = "GOOGLE_API_KEY"
    }
  }
}
