using System.Collections;
using UnityEngine;

public class HueChange : MonoBehaviour
{
    public Renderer targetRenderer;
    public float waitForSeconds = 0.0005f;
    private bool _isWaiting;
    private float _currentHueOffset;

    // Update is called once per frame
    private void Update()
    {
        StartCoroutine(ChangeHue());
    }

    private IEnumerator ChangeHue()
    {
        if (_isWaiting) yield break;
        if (_currentHueOffset >= 0 && _currentHueOffset <= 360)
            targetRenderer.material.SetFloat("_HueDegreesOffset", _currentHueOffset++);
        else
            _currentHueOffset = 0;
        _isWaiting = true;
        yield return new WaitForSeconds(waitForSeconds);
        _isWaiting = false;
    }
}