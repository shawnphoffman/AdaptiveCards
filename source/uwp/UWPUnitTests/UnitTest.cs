﻿using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Threading;
using System.Threading.Tasks;
using UWPTestLibrary;
using Windows.ApplicationModel;
using Windows.ApplicationModel.Core;
using Windows.Storage;
using Windows.UI.Core;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;

namespace UWPUnitTests
{
    [TestClass]
    public class UnitTest
    {
        public TestContext TestContext { get; set; }

        private EventWaitHandle _testCompleted = new ManualResetEvent(false);
        private Exception _exceptionThrown = null;
        private StorageFolder _tempResultsFolder;
        private StorageFolder _sourceHostConfigsFolder;
        private StorageFolder _sourceCardsFolder;
        private StorageFolder _expectedFolder;

        [ClassInitialize]
        static public async Task Init(TestContext context)
        {
            StorageFolder expectedFolder = await Package.Current.InstalledLocation.GetFolderAsync("Expected");

            context.Properties.Add("ExpectedFolder", expectedFolder);
            context.Properties.Add("ResultsFolder", await ApplicationData.Current.TemporaryFolder.CreateFolderAsync("Results", CreationCollisionOption.OpenIfExists));
            context.Properties.Add("SourceHostConfigsFolder", await expectedFolder.CreateFolderAsync("SourceHostConfigs", CreationCollisionOption.OpenIfExists));
            context.Properties.Add("SourceCardsFolder", await expectedFolder.CreateFolderAsync("SourceCards", CreationCollisionOption.OpenIfExists));
        }

        [TestMethod]
        public async Task TestMethod()
        {
            _expectedFolder = (TestContext.Properties["ExpectedFolder"] as StorageFolder);
            _tempResultsFolder = (TestContext.Properties["ResultsFolder"] as StorageFolder);
            _sourceCardsFolder = (TestContext.Properties["SourceCardsFolder"] as StorageFolder);
            _sourceHostConfigsFolder = (TestContext.Properties["SourceHostConfigsFolder"] as StorageFolder);

            ObservableCollection<FileViewModel> cards = new ObservableCollection<FileViewModel>();
            ObservableCollection<FileViewModel> hostConfigs = new ObservableCollection<FileViewModel>();

            await FileLoadHelpers.LoadAsync(cards, hostConfigs);

            List<Exception> exceptions = new List<Exception>();
            foreach (var hostConfig in hostConfigs)
            {
                foreach (var card in cards)
                {
                    try
                    {
                        await TestCardInDispatcher(hostConfig, card);
                    }
                    catch (Exception thrown)
                    {
                        exceptions.Add(thrown);
                    }
                }
            }

            if (exceptions.Count != 0)
            {
                string message = string.Empty;
                foreach (var e in exceptions)
                {
                    message += $"{e.Message}{Environment.NewLine}";
                }

                throw new Exception($"Test failed with {exceptions.Count} failures.{Environment.NewLine}{message}");
            }
        }

        public async Task TestCardInDispatcher(FileViewModel hostConfig, FileViewModel card)
        {
            _exceptionThrown = null;
            var dispatcher = CoreApplication.MainView.CoreWindow.Dispatcher;

            _testCompleted.Reset();

            // Need to move the test to the UI Thread
            await dispatcher.RunAsync(CoreDispatcherPriority.Normal, async () =>
            {
                try
                {
                    await TestCard(hostConfig, card);
                }
                catch (Exception e)
                {
                    _exceptionThrown = e;
                }
                finally
                {
                    _testCompleted.Set();
                }
            });

            _testCompleted.WaitOne();
            if (_exceptionThrown != null)
            {
                throw new Exception(_exceptionThrown.Message, _exceptionThrown);
            }
        }

        async public Task TestCard(FileViewModel hostConfigFile, FileViewModel cardFile)
        {
            var renderResult = await UWPTestLibrary.RenderTestHelpers.RenderCard(cardFile, hostConfigFile);

            if (renderResult.Item3 != null)
            {
                UWPTestLibrary.ImageWaiter imageWaiter = new ImageWaiter(renderResult.Item3);

                StackPanel stackPanel = new StackPanel();
                stackPanel.Children.Add(renderResult.Item3);

                Border border = new Border();
                border.Width = renderResult.Item4;
                border.Child = stackPanel;
                (Window.Current.Content as Frame).Content = border;

                await imageWaiter.WaitOnAllImagesAsync();

            }

            StorageFile imageResultFile = null;
            StorageFile jsonResultFile = null;
            if (renderResult.Item1 == null)
            {
                imageResultFile = await _tempResultsFolder.CreateFileAsync("Result.png", CreationCollisionOption.GenerateUniqueName);
                jsonResultFile = await _tempResultsFolder.CreateFileAsync("Result.json", CreationCollisionOption.GenerateUniqueName);

                await UWPTestLibrary.RenderTestHelpers.ResultsToFile(imageResultFile, jsonResultFile, renderResult.Item2, renderResult.Item3);
            }

            await Task.Delay(10);

            var result = await TestResultViewModel.CreateAsync(
                cardFile: cardFile,
                hostConfigFile: hostConfigFile,
                actualError: renderResult.Item1,
                actualImageFile: imageResultFile,
                actualJsonFile: jsonResultFile,
                xamlCard: renderResult.Item3,
                expectedFolder: _expectedFolder,
                sourceHostConfigsFolder: _sourceHostConfigsFolder,
                sourceCardsFolder: _sourceCardsFolder);

            if ((result.Status != TestStatus.Passed) &&
                (result.Status != TestStatus.PassedButSourceWasChanged))
            {
                throw new Exception(result.Status.ToString() + ": " + result.HostConfigName + "\\"  + result.CardName);
            }
        }
    }
}
