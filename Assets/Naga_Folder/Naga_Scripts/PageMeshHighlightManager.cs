using System;
using System.Collections.Generic;
using UnityEngine;

public class PageMeshHighlightManager : MonoBehaviour
{
    [System.Serializable]
    public class MeshHighlightEntry
    {
        [Tooltip("Drag the target MeshRenderer here.")]
        public MeshRenderer meshRenderer;

        [Tooltip("If TRUE: Highlighting automatically turns ON for THIS specific mesh when entering the page.")]
        public bool autoHighlightOnPageEnter = false;
    }

    [System.Serializable]
    public class PageHighlightConfig
    {
        [Header("Page Assignment")]
        [Tooltip("The 0-based Page Index (0 = Page 1, 1 = Page 2, etc.).")]
        [Min(0)]
        public int pageIndex = 0;

        [Header("Target Mesh Entries")]
        [Tooltip("Configure individual MeshRenderers and their auto-highlight behavior.")]
        public List<MeshHighlightEntry> meshEntries = new List<MeshHighlightEntry>();
    }

    [Header("Highlight Material")]
    [Tooltip("The outline/glow material to append to the meshes.")]
    [SerializeField] private Material highlightMaterial;

    [Header("Page Configurations")]
    [SerializeField] private List<PageHighlightConfig> pageConfigs = new List<PageHighlightConfig>();

    private readonly Dictionary<MeshRenderer, Material[]> originalMaterialsMap = new Dictionary<MeshRenderer, Material[]>();
    private readonly HashSet<MeshRenderer> activeHighlights = new HashSet<MeshRenderer>();

    private void OnEnable()
    {
        PageNavigationController.OnPageChanged += HandlePageChanged;
    }

    private void OnDisable()
    {
        PageNavigationController.OnPageChanged -= HandlePageChanged;
    }

    private void Start()
    {
        CacheOriginalMaterials();
        HandlePageChanged(PageNavigationController.CurrentIndex);
    }

    private void CacheOriginalMaterials()
    {
        foreach (PageHighlightConfig config in pageConfigs)
        {
            foreach (MeshHighlightEntry entry in config.meshEntries)
            {
                if (entry.meshRenderer != null && !originalMaterialsMap.ContainsKey(entry.meshRenderer))
                {
                    originalMaterialsMap[entry.meshRenderer] = entry.meshRenderer.sharedMaterials;
                }
            }
        }
    }

    private void HandlePageChanged(int currentPageIndex)
    {
        foreach (PageHighlightConfig config in pageConfigs)
        {
            bool isCurrentPage = (currentPageIndex == config.pageIndex);

            foreach (MeshHighlightEntry entry in config.meshEntries)
            {
                if (entry.meshRenderer == null) continue;

                if (isCurrentPage && entry.autoHighlightOnPageEnter)
                {
                    ApplyHighlightMaterial(entry.meshRenderer);
                }
                else
                {
                    RemoveHighlightMaterial(entry.meshRenderer);
                }
            }
        }
    }

    // --- UNITY EVENT FRIENDLY SINGLE-INT FUNCTIONS ---
    // You pass the Page Index (e.g. 25 for Page 26) in the Inspector input box!

    /// <summary>
    /// Turn ON highlight for Element 0 on the specified page index.
    /// </summary>
    public void EnableElement0(int pageIndex) => EnableElementHighlight(pageIndex, 0);

    /// <summary>
    /// Turn OFF highlight for Element 0 on the specified page index.
    /// </summary>
    public void DisableElement0(int pageIndex) => DisableElementHighlight(pageIndex, 0);

    /// <summary>
    /// Turn ON highlight for Element 1 on the specified page index.
    /// </summary>
    public void EnableElement1(int pageIndex) => EnableElementHighlight(pageIndex, 1);

    /// <summary>
    /// Turn OFF highlight for Element 1 on the specified page index.
    /// </summary>
    public void DisableElement1(int pageIndex) => DisableElementHighlight(pageIndex, 1);

    /// <summary>
    /// Turn ON highlight for Element 2 on the specified page index.
    /// </summary>
    public void EnableElement2(int pageIndex) => EnableElementHighlight(pageIndex, 2);

    /// <summary>
    /// Turn OFF highlight for Element 2 on the specified page index.
    /// </summary>
    public void DisableElement2(int pageIndex) => DisableElementHighlight(pageIndex, 2);


    // --- GENERAL C# / CODE FUNCTIONS ---

    public void EnableElementHighlight(int pageIndex, int elementIndex)
    {
        PageHighlightConfig config = GetConfigByPageIndex(pageIndex);
        if (config != null && elementIndex >= 0 && elementIndex < config.meshEntries.Count)
        {
            MeshRenderer renderer = config.meshEntries[elementIndex].meshRenderer;
            if (renderer != null)
            {
                ApplyHighlightMaterial(renderer);
            }
        }
    }

    public void DisableElementHighlight(int pageIndex, int elementIndex)
    {
        PageHighlightConfig config = GetConfigByPageIndex(pageIndex);
        if (config != null && elementIndex >= 0 && elementIndex < config.meshEntries.Count)
        {
            MeshRenderer renderer = config.meshEntries[elementIndex].meshRenderer;
            if (renderer != null)
            {
                RemoveHighlightMaterial(renderer);
            }
        }
    }

    public void EnableAllHighlightsForPage(int pageIndex)
    {
        PageHighlightConfig config = GetConfigByPageIndex(pageIndex);
        if (config == null || highlightMaterial == null) return;

        foreach (MeshHighlightEntry entry in config.meshEntries)
        {
            if (entry.meshRenderer != null)
            {
                ApplyHighlightMaterial(entry.meshRenderer);
            }
        }
    }

    public void DisableAllHighlightsForPage(int pageIndex)
    {
        PageHighlightConfig config = GetConfigByPageIndex(pageIndex);
        if (config == null) return;

        foreach (MeshHighlightEntry entry in config.meshEntries)
        {
            if (entry.meshRenderer != null)
            {
                RemoveHighlightMaterial(entry.meshRenderer);
            }
        }
    }

    private void ApplyHighlightMaterial(MeshRenderer renderer)
    {
        if (renderer == null || highlightMaterial == null) return;

        if (!originalMaterialsMap.ContainsKey(renderer))
        {
            originalMaterialsMap[renderer] = renderer.sharedMaterials;
        }

        List<Material> currentMats = new List<Material>(renderer.sharedMaterials);

        if (!currentMats.Contains(highlightMaterial))
        {
            currentMats.Add(highlightMaterial);
            renderer.materials = currentMats.ToArray();
            activeHighlights.Add(renderer);
        }
    }

    private void RemoveHighlightMaterial(MeshRenderer renderer)
    {
        if (renderer == null) return;

        if (originalMaterialsMap.TryGetValue(renderer, out Material[] originalMats))
        {
            renderer.materials = originalMats;
            activeHighlights.Remove(renderer);
        }
    }

    private PageHighlightConfig GetConfigByPageIndex(int pageIndex)
    {
        return pageConfigs.Find(c => c.pageIndex == pageIndex);
    }
}